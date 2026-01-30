"""
Services Routes
CRUD operations for bike services (Owner only for create/update/delete).
"""

from typing import Optional
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from ..database import get_db
from ..models.service import Service
from ..models.user import User
from ..schemas.service import ServiceCreate, ServiceUpdate, ServiceResponse, ServiceListResponse
from ..services.auth_service import get_current_user, get_current_owner


router = APIRouter(prefix="/services", tags=["Services"])


@router.get("", response_model=ServiceListResponse)
async def list_services(
    active_only: bool = Query(True, description="Filter only active services"),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """
    List all services.
    Publicly accessible for browsing.
    """
    # Build query
    query = select(Service)
    if active_only:
        query = query.where(Service.is_active == True)
    query = query.order_by(Service.created_at.desc()).offset(skip).limit(limit)
    
    # Get services
    result = await db.execute(query)
    services = result.scalars().all()
    
    # Get total count
    count_query = select(func.count()).select_from(Service)
    if active_only:
        count_query = count_query.where(Service.is_active == True)
    count_result = await db.execute(count_query)
    total = count_result.scalar()
    
    return ServiceListResponse(
        services=[ServiceResponse.model_validate(s) for s in services],
        total=total
    )


@router.get("/{service_id}", response_model=ServiceResponse)
async def get_service(
    service_id: UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    Get a specific service by ID.
    """
    result = await db.execute(select(Service).where(Service.id == service_id))
    service = result.scalar_one_or_none()
    
    if not service:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service not found"
        )
    
    return ServiceResponse.model_validate(service)


@router.post("", response_model=ServiceResponse, status_code=status.HTTP_201_CREATED)
async def create_service(
    service_data: ServiceCreate,
    current_owner: User = Depends(get_current_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    Create a new service.
    Owner only.
    """
    new_service = Service(
        name=service_data.name,
        description=service_data.description,
        price=service_data.price,
        estimated_time=service_data.estimated_time
    )
    
    db.add(new_service)
    await db.flush()
    await db.refresh(new_service)
    
    return ServiceResponse.model_validate(new_service)


@router.put("/{service_id}", response_model=ServiceResponse)
async def update_service(
    service_id: UUID,
    service_data: ServiceUpdate,
    current_owner: User = Depends(get_current_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    Update an existing service.
    Owner only.
    """
    result = await db.execute(select(Service).where(Service.id == service_id))
    service = result.scalar_one_or_none()
    
    if not service:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service not found"
        )
    
    # Update fields if provided
    update_data = service_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(service, field, value)
    
    await db.flush()
    await db.refresh(service)
    
    return ServiceResponse.model_validate(service)


@router.delete("/{service_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_service(
    service_id: UUID,
    current_owner: User = Depends(get_current_owner),
    db: AsyncSession = Depends(get_db)
):
    """
    Delete a service (soft delete by deactivating).
    Owner only.
    """
    result = await db.execute(select(Service).where(Service.id == service_id))
    service = result.scalar_one_or_none()
    
    if not service:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service not found"
        )
    
    # Soft delete - just deactivate
    service.is_active = False
    await db.commit()
    
    return None
