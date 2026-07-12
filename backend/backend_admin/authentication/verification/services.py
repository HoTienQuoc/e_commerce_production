import logging
from math import e
import traceback
from django.core.cache import cache
from django.contrib.auth import get_user_model

from backend.backend_admin.authentication.auth.services import send_verification_email_task
from backend.backend_admin.authentication.verification.tokens import TokenVerifier

User = get_user_model()
logger = logging.getLogger(__name__)

class EmailVerificationService:
    """service class to handle email verification operations"""
    @staticmethod
    def get_verification_cache_key(user_id):
        """Get standardized cache key for user verification status"""
        return f"user_verified_status_{user_id}"
    
    @staticmethod
    def check_verification_status(user):
        """check email verification status"""
        try:
            cache_key = EmailVerificationService.get_verification_cache_key(user.pk)
            cached_status = cache.get(cache_key)
            if cached_status is not None:
                logger.info(f"Using cached verification status for user {user.pk}: {cached_status}")
                return True, {
                    "success" : True,
                    "data": {'is_verified':cached_status}
                }, 200

            try:
                fresh_user = User.objects.get(pk = user.pk)
                is_verified = fresh_user.is_verified # pyright: ignore[reportAttributeAccessIssue]

                # Cache the result for future queries
                cache.set(cache_key, is_verified, timeout=3600)

                logger.info(f"Fetched verification status from DB from user {user.pk}: {is_verified}")

                return True, {
                    "success" : True,
                    "data" : {"is_verified": is_verified}
                }, 200
            
            except User.DoesNotExist:
                logger.error(f"User {user.pk} not found in database")
                return False, {
                    "success" : False,
                    "error" : "User not found"
                }, 400
        except Exception as e:
            logger.error(f"check verification status error: {str(e)}")
            return True, {
                "success" : True,
                "data" : {"is_verified": user.is_verified},
                "message" : "Could not check latest status, using existing information"
            }, 200

    @staticmethod
    def verify_email(uidb64, token):
        """Verify email with token"""
        is_valid, user, error = TokenVerifier.verify_token(uidb64, token)
        
        if not is_valid:
            logger.warning(f"Invalid token verification attempt with uidb64")
            return False, {"success":False, "error":error or "Invalid verification link. Please request a new one."}, 400
        
        try:
            from django.db import transaction
            with transaction.atomic():
                if not user.is_verified:  # pyright: ignore[reportAttributeAccessIssue, reportOptionalMemberAccess]
                    user.is_verified = True # pyright: ignore[reportAttributeAccessIssue, reportOptionalMemberAccess]
                    user.save(update_fields=['is_verified']) # pyright: ignore[reportOptionalMemberAccess]
                else:
                    logger.info(f"Email verification attempt for already verified user: {user.id} ({user.email})") # pyright: ignore[reportOptionalMemberAccess, reportAttributeAccessIssue]
            
            cache_key = EmailVerificationService.get_verification_cache_key(user.id) # pyright: ignore[reportAttributeAccessIssue, reportOptionalMemberAccess]
            cache.set(cache_key, True, timeout = 3600)
            logger.info(f"Updated verification cache for user {user.id} : set to True") # pyright: ignore[reportAttributeAccessIssue, reportOptionalMemberAccess]

            return True,{
                "success": True,
                "message": "Email verification successful." 
            }, 200
        
        except Exception as e:
            logger.error(f"Error during verification: {str(e)}")
            return True, {
                "success": False,
                "error": "An error occured during verification. Please try again"
            }, 500
    
    @staticmethod
    def send_verification_email(user):
        """Send Verification email to user"""
        try:
            if user.is_verified:
                return True, {
                    "success" : True, 
                    "message" : "Email is already verified."
                }, 200
            rate_key = f"verification_email_{user.id}"
            if cache.get(rate_key):
                return False, {
                    "success": False,
                    "error": "Please wait before requesting another verification email."
                }, 429
            
            send_verification_email_task.delay(user.id) # pyright: ignore[reportCallIssue]

            cache.set(rate_key, True, timeout=300)
            logger.info(f"Verification email task queued for {user.email}")

            return True, {
                "success": True,
                "message": "A verification link has been sent to your email"
            }, 200
        
        except Exception as e:
            logger.error(f"Error queueing verification email: {str(e)}")

            return False, {
                "success": False,
                "error": "Failed to send verification email. Please try again later."
            }, 500
        
        except Exception as e: # pyright: ignore[reportUnusedExcept]
            logger.error(f"Send verification email error: {str(e)}")
            return False,{
                "success":False,
                "error": "Failed to send verification email. Please try again later."
            },400
        

