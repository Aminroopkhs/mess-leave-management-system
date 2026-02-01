from fastapi import APIRouter, HTTPException, status, Depends
from google.oauth2 import id_token
from google.auth.transport import requests
import os
from ..models.auth import UserResponse, GoogleAuthRequest, AuthResponse
from ..utils.jwt import create_access_token, verify_token
from domain.interfaces.user_repository import IUserRepository
from _bootstrap.dependencies import get_user_repository

router = APIRouter(prefix="/auth", tags=["Authentication"])

# Get Google Client ID from environment variable
# You need to set this in your .env file
GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID", "")

@router.post("/google", response_model=AuthResponse)
async def google_auth(
    auth_request: GoogleAuthRequest,
    user_repo: IUserRepository = Depends(get_user_repository)
):
    """
    Verify Google ID token and authenticate user
    
    Args:
        auth_request: Contains the Google ID token from the Flutter app
        user_repo: User repository (injected)
        
    Returns:
        AuthResponse: JWT access token and user information
        
    Raises:
        HTTPException: If token verification fails
    """
    try:
        # Verify the token with Google
        idinfo = id_token.verify_oauth2_token(
            auth_request.id_token,
            requests.Request(),
            GOOGLE_CLIENT_ID
        )

        # Token is valid, extract user information
        user_id = idinfo['sub']
        email = idinfo['email']
        name = idinfo.get('name', '')
        picture = idinfo.get('picture', '')
        email_verified = idinfo.get('email_verified', False)

        # Optional: Check if email domain matches your institution
        # if not email.endswith('@yourinstitution.edu'):
        #     raise HTTPException(
        #         status_code=status.HTTP_403_FORBIDDEN,
        #         detail="Only institutional email addresses are allowed"
        #     )
        
        # Check if user exists in database
        existing_user = await user_repo.get_by_id(user_id)
        
        if existing_user:
            # Update last login time
            await user_repo.update_last_login(user_id)
        else:
            # Create new user
            await user_repo.create({
                "id": user_id,
                "email": email,
                "name": name,
                "picture": picture,
                "email_verified": email_verified
            })

        # Create JWT token with user_id as subject
        access_token = create_access_token(
            data={
                "sub": user_id,
                "email": email,
                "name": name
            }
        )

        # Create user response object
        user = UserResponse(
            email=email,
            name=name,
            picture=picture,
            user_id=user_id,
            email_verified=email_verified
        )

        # Return JWT token with user info
        return AuthResponse(
            access_token=access_token,
            user=user
        )

    except ValueError as e:
        # Invalid token
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication token: {str(e)}"
        )
    except Exception as e:
        # Other errors
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Authentication failed: {str(e)}"
        )


@router.post("/logout")
async def logout(token_data: dict = Depends(verify_token)):
    """
    Logout endpoint
    
    Args:
        token_data: Verified JWT token data
    
    Returns:
        Success message
    
    Note:
        With JWTs, logout is primarily client-side (delete token).
        You could maintain a token blacklist for enhanced security.
    """
    # TODO: Add token to blacklist/revoked tokens table
    return {"message": "Logged out successfully"}


@router.get("/user/me", response_model=UserResponse)
async def get_current_user(
    token_data: dict = Depends(verify_token),
    user_repo: IUserRepository = Depends(get_user_repository)
):
    """
    Get current authenticated user information from database
    
    Args:
        token_data: Verified JWT token data from Authorization header
        user_repo: User repository (injected)
        
    Returns:
        User information from the database
    """
    user_id = token_data.get("sub")
    
    # Get user from database
    user_data = await user_repo.get_by_id(user_id)
    
    if not user_data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return UserResponse(
        email=user_data["email"],
        name=user_data["name"],
        user_id=user_data["id"],
        email_verified=user_data["email_verified"],
        picture=user_data.get("picture")
    )
