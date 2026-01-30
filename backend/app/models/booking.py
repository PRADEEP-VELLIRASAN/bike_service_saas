"""
Booking Model
Represents service bookings made by customers.
"""

import uuid
from datetime import datetime, date
from enum import Enum as PyEnum
from sqlalchemy import Column, String, Text, Float, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from ..database import Base


class BookingStatus(str, PyEnum):
    """Booking status workflow."""
    PENDING = "pending"
    CONFIRMED = "confirmed"
    IN_PROGRESS = "in_progress"
    READY_FOR_DELIVERY = "ready_for_delivery"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class Booking(Base):
    """Booking model for service appointments."""
    
    __tablename__ = "bookings"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    customer_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    booking_date = Column(Date, nullable=False)
    status = Column(String(30), nullable=False, default=BookingStatus.PENDING.value)
    total_price = Column(Float, nullable=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    customer = relationship("User", back_populates="bookings")
    booking_services = relationship("BookingService", back_populates="booking", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<Booking(id={self.id}, customer_id={self.customer_id}, status={self.status})>"
    
    @property
    def services(self):
        """Get list of services in this booking."""
        return [bs.service for bs in self.booking_services]
    
    @property
    def status_display(self) -> str:
        """Get human-readable status."""
        status_map = {
            "pending": "Pending",
            "confirmed": "Confirmed",
            "in_progress": "In Progress",
            "ready_for_delivery": "Ready for Delivery",
            "completed": "Completed",
            "cancelled": "Cancelled"
        }
        status_val = self.status.value if hasattr(self.status, 'value') else self.status
        return status_map.get(status_val, status_val)


class BookingService(Base):
    """Association table for booking-service relationship."""
    
    __tablename__ = "booking_services"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    booking_id = Column(String(36), ForeignKey("bookings.id", ondelete="CASCADE"), nullable=False)
    service_id = Column(String(36), ForeignKey("services.id", ondelete="CASCADE"), nullable=False)
    service_price = Column(Float, nullable=False)  # Price at time of booking
    
    # Relationships
    booking = relationship("Booking", back_populates="booking_services")
    service = relationship("Service", back_populates="booking_services")
    
    def __repr__(self):
        return f"<BookingService(booking_id={self.booking_id}, service_id={self.service_id})>"
