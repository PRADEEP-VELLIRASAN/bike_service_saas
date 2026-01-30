"""
Authentication Routes
Handles user registration, login, and verification.
"""

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from ..database import get_db
from ..models.user import User
from ..schemas.user import UserCreate, UserLogin, UserResponse, Token
from ..services.auth_service import AuthService, get_current_user
from ..services.email_service import EmailService


router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
async def register(
    user_data: UserCreate,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db)
):
    """
    Register a new user (Owner or Customer).
    Sends verification email in background.
    """
    # Check if email already exists
    existing_user = await AuthService.get_user_by_email(db, user_data.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create verification token
    verification_token = AuthService.create_verification_token()
    
    # Create new user
    new_user = User(
        email=user_data.email,
        password_hash=AuthService.hash_password(user_data.password),
        name=user_data.name,
        phone=user_data.phone,
        role=user_data.role,
        verification_token=verification_token,
        is_verified=True  # Set to True for now, change to False for email verification
    )
    
    db.add(new_user)
    await db.flush()
    await db.refresh(new_user)
    
    # Send verification email in background
    background_tasks.add_task(
        EmailService.send_verification_email,
        to_email=new_user.email,
        name=new_user.name,
        token=verification_token
    )
    
    # Generate access token
    access_token = AuthService.create_access_token(new_user)
    
    return Token(
        access_token=access_token,
        user=UserResponse.model_validate(new_user)
    )


@router.post("/login", response_model=Token)
async def login(
    credentials: UserLogin,
    db: AsyncSession = Depends(get_db)
):
    """
    Login with email and password.
    Returns JWT access token.
    """
    # Find user by email
    user = await AuthService.get_user_by_email(db, credentials.email)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Verify password
    if not AuthService.verify_password(credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Check if user is verified (optional - can be enabled)
    # if not user.is_verified:
    #     raise HTTPException(
    #         status_code=status.HTTP_403_FORBIDDEN,
    #         detail="Please verify your email before logging in"
    #     )
    
    # Generate access token
    access_token = AuthService.create_access_token(user)
    
    return Token(
        access_token=access_token,
        user=UserResponse.model_validate(user)
    )


@router.post("/verify-email")
async def verify_email(
    token: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Verify user's email address using the token sent via email.
    """
    # Find user by verification token
    result = await db.execute(
        select(User).where(User.verification_token == token)
    )
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid verification token"
        )
    
    # Mark user as verified
    user.is_verified = True
    user.verification_token = None
    await db.commit()
    
    return {"message": "Email verified successfully"}


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user)
):
    """
    Get current authenticated user's profile.
    """
    return UserResponse.model_validate(current_user)


@router.post("/resend-verification")
async def resend_verification(
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Resend verification email.
    """
    if current_user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already verified"
        )
    
    # Generate new verification token
    new_token = AuthService.create_verification_token()
    current_user.verification_token = new_token
    await db.commit()
    
    # Send email in background
    background_tasks.add_task(
        EmailService.send_verification_email,
        to_email=current_user.email,
        name=current_user.name,
        token=new_token
    )
    
    return {"message": "Verification email sent"}
