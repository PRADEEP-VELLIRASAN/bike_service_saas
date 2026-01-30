"""
Service Schemas
Pydantic models for service-related request/response validation.
"""

from pydantic import BaseModel, Field, field_validator
from typing import Optional
from uuid import UUID
from datetime import datetime
from decimal import Decimal


class ServiceCreate(BaseModel):
    """Schema for creating a new service."""
    name: str = Field(..., min_length=2, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    price: Decimal = Field(..., ge=0)
    estimated_time: int = Field(..., gt=0, le=480)  # max 8 hours
    
    @field_validator('price')
    @classmethod
    def validate_price(cls, v):
        if v < 0:
            raise ValueError('Price must be positive')
        return round(v, 2)


class ServiceUpdate(BaseModel):
    """Schema for updating a service."""
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    price: Optional[Decimal] = Field(None, ge=0)
    estimated_time: Optional[int] = Field(None, gt=0, le=480)
    is_active: Optional[bool] = None



class ServiceResponse(BaseModel):
    """Schema for service response."""
    id: UUID
    name: str
    description: Optional[str]
    price: Decimal
    estimated_time: int
    estimated_time_display: str
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class ServiceListResponse(BaseModel):
    """Schema for list of services response."""
    services: list[ServiceResponse]
    total: int
