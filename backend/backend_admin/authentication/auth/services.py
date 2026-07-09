import logging
from tkinter.constants import NO
import traceback

from django.utils import timezone
from django.conf import settings
from django.core.cache import cache
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

from authentication.serializers import UserSerializer
from authentication.core.jwt_utils import TokenManager
from authentication.models import CustomUser
from rest_framework_simplejwt.tokens import RefreshToken
from authentication.verification.tasks import send_verification_email_task
from backend.backend_admin.authentication import serializers

logger = logging.getLogger(__name__)

class AuthenticationService:
    """Service class to handle authentication-related business logic"""
    @staticmethod
    def register(email, password, phone_number = None, first_name = None, last_name = None, request_meta = None, request = None):
        """Handle user registration with email and password"""
        if not email or not password:
            return False, {
                "success" : False,
                "error" : "Email and password are required."
            }, 400
        # log registration attempt
        if request_meta: 
            logger.info(f"Registration attempt from IP: {request_meta.get('REMOTE_ADDR')}")
        try:
            # check if email already exists
            if CustomUser.objects.filter(email = email).exists():
                return False, {"success":False, "error":"A user with this email already exists."}, 400
            
            # validate password strength
            try:
                validate_password(password)
            except ValidationError as e:
                return False, {"success":False, "error":", ".join(e.messages)}, 400

            # create new user
            user = CustomUser.objects.create_user(email = email, password = password, is_verified = False) # pyright: ignore[reportAttributeAccessIssue]

            if first_name:
                user.first_name = first_name
                user.save(update_fields = ['full_name'])
            
            if last_name:
                user.last_name = last_name
                user.save(update_fields = ['last_name'])
            
            if phone_number:
                user.phone_number = phone_number
                user.save(update_fields = ['phone_number'])

            # Queue verification email for new users asynchronously
            if user.email and settings.REQUIRE_EMAIL_VERIFICATION:
                try:
                    send_verification_email_task.delay(user.id) # pyright: ignore[reportCallIssue]
                    logger.info(f"Queued verification email for new user: {user.email}")
                except Exception as e:
                    logger.error(f"Failed to queue verification email task for user {user.id}: {str(e)}")

            # Serialize user data with request context
            context = {}
            if request:
                context['request'] = request
            serializers = UserSerializer(user, context= context)

            # Generate tokens
            tokens = TokenManager.generate_tokens(user)

            logger.info(f"Registration successful for user: {user.email}")

            # Return successful response data
            return True, {
                "success" : True,
                "data" : {
                    "user" : serializers.data,
                    "tokens" : tokens,
                    "is_new_user" : True,
                    "email_verified" : user.is_verified
                }
            }, 201
        
        except Exception as e:
            logger.error(f"Registration error: {str(e)}")
            return False, {
                "success": False,
                "error": "Registration failed. Please try again"
            }, 400

    @staticmethod
    def login(email,password, device_info=None, request_meta=None, request=None):
        """Handle user login with email and password"""
        if not email or not password:
            return False, {
                "success":False, "error":"Email and password are required."
            }, 400
        if request_meta:
            logger.info(f"Login attempt from IP: {request_meta.get('REMOTE_ADDR')}, User-Agent: {request_meta.get('HTTP_USER_AGENT')}")
        try:
            # check for account lockout
            if cache.get(f"account_lockout: {email}"):
                logger.warning(f"Login attempt for locked account: {email}")
                return False, {
                    "success": False,
                    "error" : "Account temporarily locked due to multiple failed attempts. Try again later.",
                    "lockout": True,
                }, 403
            
            # check if user exists first
            try:
                user_exists = CustomUser.objects.filter(email = email).exists()

                if not user_exists:
                    logger.warning(f"Login attempt for non-existent email: {email}")
                    failed_attempts = cache.get(f"failed_login: {email}", 0) + 1
                    cache.set(f"failed_logins: {email}", failed_attempts, timeout=1800)
                    return False,{
                        "success" : False,
                        "error": "Invalid email or password"
                    }, 401
            except Exception as user_check_error:
                logger.error(f"Error checking user existence: {str(user_check_error)}")
                return False, {
                    "success" : False,
                    "error" : "Database error occurred"
                }, 500
            


        

