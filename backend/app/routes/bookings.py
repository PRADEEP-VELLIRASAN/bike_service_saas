"""
Bookings Routes
Handles booking creation, listing, and status updates.
"""

from typing import Optional, List
from uuid import UUID
from datetime import date
from fastapi import APIRouter, Depends, HTTPException, status, Query, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload

from ..database import get_db
from ..models.user import User, UserRole
from ..models.service import Service
from ..models.booking import Booking, BookingStatus
from ..models.booking_service import BookingService
from ..schemas.booking import (
    BookingCreate, BookingUpdate, BookingResponse,
    BookingStatusUpdate, BookingListResponse, BookingServiceInfo
)
from ..schemas.user import UserResponse
from ..services.auth_service import get_current_user, get_current_owner, get_current_customer
from ..services.email_service import EmailService


router = APIRouter(prefix="/bookings", tags=["Bookings"])


def build_booking_response(booking: Booking) -> BookingResponse:
    """Build booking response with all related data."""
    services_info = [
        BookingServiceInfo(
            service_id=bs.service_id,
            service_name=bs.service.name,
            service_price=bs.service_price
        )
        for bs in booking.booking_services
    ]
    
    return BookingResponse(
        id=booking.id,
        customer=UserResponse.model_validate(booking.customer),
        booking_date=booking.booking_date,
        status=booking.status,
        status_display=booking.status_display,
        total_price=booking.total_price,
        notes=booking.notes,
        services=services_info,
        created_at=booking.created_at,
        updated_at=booking.updated_at
    )


@router.get("", response_model=BookingListResponse)
async def list_bookings(
    status_filter: Optional[BookingStatus] = Query(None, description="Filter by status"),
    date_from: Optional[date] = Query(None, description="Filter from date"),
    date_to: Optional[date] = Query(None, description="Filter to date"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    List bookings.
    - Owners see all bookings
    - Customers see only their own bookings
    """
    query = select(Booking).options(
        selectinload(Booking.customer),
        selectinload(Booking.booking_services).selectinload(BookingService.service)
    )
    
    # Role-based filtering
    if current_user.role == UserRole.CUSTOMER:
        query = query.where(Booking.customer_id == current_user.id)
    
    # Apply filters
    if status_filter:
        query = query.where(Booking.status == status_filter)
    if date_from:
        query = query.where(Booking.booking_date >= date_from)
    if date_to:
        query = query.where(Booking.booking_date <= date_to)
    
    # Order and paginate
    skip = (page - 1) * page_size
    query = query.order_by(Booking.created_at.desc()).offset(skip).limit(page_size)
    
    # Execute query
    result = await db.execute(query)
    bookings = result.scalars().all()
    
    # Get total count
    count_query = select(func.count()).select_from(Booking)
    if current_user.role == UserRole.CUSTOMER:
        count_query = count_query.where(Booking.customer_id == current_user.id)
    if status_filter:
        count_query = count_query.where(Booking.status == status_filter)
    if date_from:
        count_query = count_query.where(Booking.booking_date >= date_from)
    if date_to:
        count_query = count_query.where(Booking.booking_date <= date_to)
    
    count_result = await db.execute(count_query)
    total = count_result.scalar()
    
    return BookingListResponse(
        bookings=[build_booking_response(b) for b in bookings],
        total=total,
        page=page,
        page_size=page_size
    )


@router.get("/{booking_id}", response_model=BookingResponse)
async def get_booking(
    booking_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Get booking details by ID.
    - Owners can view any booking
    - Customers can only view their own bookings
    """
    query = select(Booking).options(
        selectinload(Booking.customer),
        selectinload(Booking.booking_services).selectinload(BookingService.service)
    ).where(Booking.id == booking_id)
    
    result = await db.execute(query)
    booking = result.scalar_one_or_none()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Check access
    if current_user.role == UserRole.CUSTOMER and booking.customer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this booking"
        )
    
    return build_booking_response(booking)


@router.post("", response_model=BookingResponse, status_code=status.HTTP_201_CREATED)
async def create_booking(
    booking_data: BookingCreate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_customer),
    db: AsyncSession = Depends(get_db)
):
    """
    Create a new booking.
    Customer only.
    """
    # Fetch all selected services
    result = await db.execute(
        select(Service).where(
            Service.id.in_(booking_data.service_ids),
            Service.is_active == True
        )
    )
    services = result.scalars().all()
    
    if len(services) != len(booking_data.service_ids):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="One or more services not found or inactive"
        )
    
    # Calculate total price
    total_price = sum(s.price for s in services)
    
    # Create booking
    new_booking = Booking(
        customer_id=current_user.id,
        booking_date=booking_data.booking_date,
        status=BookingStatus.PENDING,
        total_price=total_price,
        notes=booking_data.notes
    )
    
    db.add(new_booking)
    await db.flush()
    
    # Create booking_services junction records
    for service in services:
        booking_service = BookingService(
            booking_id=new_booking.id,
            service_id=service.id,
            service_price=service.price
        )
        db.add(booking_service)
    
    await db.flush()
    
    # Reload with relationships
    await db.refresh(new_booking)
    result = await db.execute(
        select(Booking).options(
            selectinload(Booking.customer),
            selectinload(Booking.booking_services).selectinload(BookingService.service)
        ).where(Booking.id == new_booking.id)
    )
    new_booking = result.scalar_one()
    
    # Prepare services info for emails
    services_info = [{"name": s.name, "price": float(s.price)} for s in services]
    
    # Send confirmation email to customer
    background_tasks.add_task(
        EmailService.send_booking_confirmation,
        to_email=current_user.email,
        customer_name=current_user.name,
        booking_id=str(new_booking.id),
        booking_date=str(booking_data.booking_date),
        services=services_info,
        total_price=float(total_price)
    )
    
    # Notify all owners about new booking
    owners_result = await db.execute(
        select(User).where(User.role == UserRole.OWNER)
    )
    owners = owners_result.scalars().all()
    
    for owner in owners:
        background_tasks.add_task(
            EmailService.send_new_booking_to_owner,
            owner_email=owner.email,
            customer_name=current_user.name,
            customer_email=current_user.email,
            customer_phone=current_user.phone,
            booking_id=str(new_booking.id),
            booking_date=str(booking_data.booking_date),
            services=services_info,
            total_price=float(total_price)
        )
    
    return build_booking_response(new_booking)


@router.put("/{booking_id}/status", response_model=BookingResponse)
async def update_booking_status(
    booking_id: UUID,
    status_update: BookingStatusUpdate,
    background_tasks: BackgroundTasks,
    current_owner: User = Depends(get_current_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    Update booking status.
    Owner only.
    Sends notification when status changes to 'ready_for_delivery'.
    """
    query = select(Booking).options(
        selectinload(Booking.customer),
        selectinload(Booking.booking_services).selectinload(BookingService.service)
    ).where(Booking.id == booking_id)
    
    result = await db.execute(query)
    booking = result.scalar_one_or_none()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    old_status = booking.status
    booking.status = status_update.status
    
    await db.flush()
    await db.refresh(booking)
    
    # Send email notification when bike is ready for delivery
    if status_update.status == BookingStatus.READY_FOR_DELIVERY and old_status != BookingStatus.READY_FOR_DELIVERY:
        background_tasks.add_task(
            EmailService.send_ready_for_delivery,
            to_email=booking.customer.email,
            customer_name=booking.customer.name,
            booking_id=str(booking.id)
        )
    
    return build_booking_response(booking)


@router.delete("/{booking_id}", status_code=status.HTTP_204_NO_CONTENT)
async def cancel_booking(
    booking_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Cancel a booking.
    - Customers can cancel their own pending bookings
    - Owners can cancel any booking
    """
    result = await db.execute(select(Booking).where(Booking.id == booking_id))
    booking = result.scalar_one_or_none()
    
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Access control
    if current_user.role == UserRole.CUSTOMER:
        if booking.customer_id != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to cancel this booking"
            )
        if booking.status not in [BookingStatus.PENDING, BookingStatus.CONFIRMED]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot cancel booking in current status"
            )
    
    # Cancel booking
    booking.status = BookingStatus.CANCELLED
    await db.commit()
    
    return None
