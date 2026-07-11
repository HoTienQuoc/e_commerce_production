import logging
import traceback

from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.throttling import AnonRateThrottle, UserRateThrottle

from authentication.core.base_view import BaseAPIView
from authentication.core.response import standardized_response

from .services import EmailVerificationService, User

logger = logging.getLogger(__name__)

class VerifyEmailView(BaseAPIView):
    """Endpoint for everything email with token"""
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]

    def post(self, request):
        try:
            uidb64 = request.data.get('uid') or request.query_params.get('uid')
            token = request.data.get('token') or request.query_params.get('token')

            if not uidb64 or not token:
                return Response(standardized_response(success=False, error = "Missing required fields"), status=status.HTTP_400_BAD_REQUEST)