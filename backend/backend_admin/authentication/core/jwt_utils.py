from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from datetime import datetime, timedelta
from django.conf import settings
from django.core.cache import cache
import jwt
import logging
import uuid
import time
from django.utils import timezone
from django_redis import get_redis_connection

logger = logging.getLogger(__name__)

class TokenManager:
    """Enhanced JWT token manager with Redis caching"""
    @staticmethod
    def _get_redis_connection():
        """Get a raw redis-py client"""
        return get_redis_connection("default")
    
    @staticmethod
    def generate_tokens(user):
        """Generate secure access and refresh tokens with enhanced claims and security"""
        try:
            refresh = RefreshToken.for_user(user)
            # Create unique JTI (JWT ID) for better tracking
            jti = str(uuid.uuid4())
            # Add custom claims with security considerations.
            refresh['jti'] = jti
            refresh['username'] = user.username
            refresh['is_staff'] = user.is_staff
            refresh['email'] = user.email
            refresh['is_verified'] = user.is_verified
            refresh['type'] = 'refresh'

            # Set up different claims for access token
            access_token = refresh.access_token
            access_token['type'] = 'access'
            access_token['jti'] = str(uuid.uuid4())

            access_expiry = settings.SIMPLE_JWT.get('ACCESS_TOKEN_LIFETIME', timedelta(minutes=15))

            refresh_expiry = settings.SIMPLE_JWT.get('REFRESH_TOKEN_LIFETIME', timedelta(days=14))

    @staticmethod
    def _store_token_metadata(user_id, jti, expiry_seconds):
        """Store token metadata in Redis for blacklisting"""
        try:
            redis_client = TokenManager._get_redis_connection()
            user_tokens_key = f"user_tokens:{user_id}"

            pipe = redis_client.pipeline()
            pipe.sadd(user_tokens_key, jti)
            pipe.expire(user_tokens_key, int(expiry_seconds))
            pipe.execute()
        except Exception as e:
            logger.error(f"Error storing token metadata in Redis: {str(e)}")
