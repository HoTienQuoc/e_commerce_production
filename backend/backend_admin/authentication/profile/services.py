import base64
import json
import logging
import os
from django.core.files.base import ContentFile
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from authentication.core.jwt_utils import TokenManager
from authentication.serializers import UserSerializer

logger = logging.getLogger(__name__)

class ProfileService:
    """Service class to handle user profile operations"""

    @staticmethod
    def get_profile(user, request=None):
        """Get user profile data"""
        context = {'request':request} if request else {}
        serializers = UserSerializer(user, context = context)
        return serializers.data
    
    
