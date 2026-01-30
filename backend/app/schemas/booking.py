"""
Booking Schemas
Pydantic models for booking-related request/response validation.
"""

from pydantic import BaseModel, Field, field_validator
from typing import Optional, List
from uuid import UUID
from datetime import datetime, date
from decimal import Decimal
from ..models.booking import BookingStatus
from .service import ServiceResponse
from .user import UserResponse


class BookingServiceInfo(BaseModel):
    """Schema for service info in a booking."""
    service_id: UUID
    service_name: str
    service_price: Decimal
    
    class Config:
        from_attributes = True


class BookingCreate(BaseModel):
    """Schema for creating a new booking."""
    service_ids: List[UUID] = Field(..., min_length=1)
    booking_date: date
    notes: Optional[str] = Field(None, max_length=500)
    
    @field_validator('booking_date')
    @classmethod
    def validate_booking_date(cls, v):
        if v < date.today():
            raise ValueError('Booking date cannot be in the past')
        return v


class BookingUpdate(BaseModel):
    """Schema for updating a booking."""
    booking_date: Optional[date] = None
    notes: Optional[str] = Field(None, max_length=500)
    
    @field_validator('booking_date')
    @classmethod
    def validate_booking_date(cls, v):
        if v and v < date.today():
            raise ValueError('Booking date cannot be in the past')
        return v


class BookingStatusUpdate(BaseModel):
    """Schema for updating booking status (Owner only)."""
    status: BookingStatus
    
    @field_validator('status')
    @classmethod
    def validate_status(cls, v):
        # Define valid status transitions
        valid_statuses = [
            BookingStatus.CONFIRMED,
            BookingStatus.IN_PROGRESS,
            BookingStatus.READY_FOR_DELIVERY,
            BookingStatus.COMPLETED,
            BookingStatus.CANCELLED
        ]
        if v not in valid_statuses:
            raise ValueError(f'Invalid status. Must be one of: {[s.value for s in valid_statuses]}')
        return v


class BookingResponse(BaseModel):
    """Schema for booking response."""
    id: UUID
    customer: UserResponse
    booking_date: date
    status: BookingStatus
    status_display: str
    total_price: Decimal
    notes: Optional[str]
    services: List[BookingServiceInfo]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class BookingListResponse(BaseModel):
    """Schema for list of bookings response."""
    bookings: List[BookingResponse]
    total: int
    page: int
    page_size: int


class BookingCustomerView(BaseModel):
    """Schema for customer's view of their booking."""
    id: UUID
    booking_date: date
    status: BookingStatus
    status_display: str
    total_price: Decimal
    notes: Optional[str]
    services: List[BookingServiceInfo]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
