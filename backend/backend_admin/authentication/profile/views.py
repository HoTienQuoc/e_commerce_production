import logging
import traceback
from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.throttling import UserRateThrottle
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser

from authentication.core.base_view import BaseAPIView
from authentication.core.response import standardized_response
from .services import ProfileService

logger = logging.getLogger(__name__)

class UserProfileView(BaseAPIView):
    """Api endpoint for user profile operations"""
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    throttle_classes = [UserRateThrottle]

    def get(self, request):
        """Get user profile data"""
        try:
            user_data = ProfileService.get_profile(request.user, request = request)

            return Response(
                standardized_response(
                    success=True,
                    data = user_data
                )
            )
        
        except Exception as e:
            logger.error(f"Profile fetch error: {str(e)}")
            logger.error(traceback.format_exc())

            return Response(
                standardized_response(success=False, error = "Failed to retrieve profile"), status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def put(self, request):
        """Update full user profile"""
        try:
