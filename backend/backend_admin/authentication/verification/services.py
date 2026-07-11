import logging
import traceback
from django.core.cache import cache
from django.contrib.auth import get_user_model

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
