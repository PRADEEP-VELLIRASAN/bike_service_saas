"""
Service Model
Represents bike services offered by the station.
"""

import uuid
from datetime import datetime
from sqlalchemy import Column, String, Text, Float, Integer, Boolean, DateTime
from sqlalchemy.orm import relationship
from ..database import Base


class Service(Base):
    """Service model for bike services."""
    
    __tablename__ = "services"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    price = Column(Float, nullable=False)
    estimated_time = Column(Integer, nullable=False)  # in minutes
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    booking_services = relationship("BookingService", back_populates="service")
    
    def __repr__(self):
        return f"<Service(id={self.id}, name={self.name}, price={self.price})>"
    
    @property
    def estimated_time_display(self) -> str:
        """Get human-readable estimated time."""
        hours = self.estimated_time // 60
        minutes = self.estimated_time % 60
        if hours > 0:
            return f"{hours}h {minutes}m" if minutes > 0 else f"{hours}h"
        return f"{minutes}m"
