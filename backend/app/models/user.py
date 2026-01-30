"""
User Model
Represents both owners and customers in the system.
"""

import uuid
from datetime import datetime
from enum import Enum as PyEnum
from sqlalchemy import Column, String, Boolean, DateTime, Enum
from sqlalchemy.orm import relationship
from ..database import Base


class UserRole(str, PyEnum):
    """User roles in the system."""
    OWNER = "owner"
    CUSTOMER = "customer"


class User(Base):
    """User model for authentication and authorization."""
    
    __tablename__ = "users"
    
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    name = Column(String(100), nullable=False)
    phone = Column(String(20), nullable=False)
    role = Column(String(20), nullable=False, default=UserRole.CUSTOMER.value)
    is_verified = Column(Boolean, default=False)
    verification_token = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    bookings = relationship("Booking", back_populates="customer", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<User(id={self.id}, email={self.email}, role={self.role})>"
    
    @property
    def is_owner(self) -> bool:
        """Check if user is an owner."""
        return self.role == UserRole.OWNER.value or self.role == UserRole.OWNER
    
    @property
    def is_customer(self) -> bool:
        """Check if user is a customer."""
        return self.role == UserRole.CUSTOMER.value or self.role == UserRole.CUSTOMER
