import logging
import traceback
from django.utils import timezone
from django.conf import settings
from django.middleware.csrf import get_token
from datetime import timedelta
from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.throttling import AnonRateThrottle, UserRateThrottle
from rest_framework_simplejwt.tokens import RefreshToken
from authentication.core.base_view import BaseAPIView

from authentication.core.response import standardized_response
from .services import AuthenticationService

logger = logging.getLogger(__name__)

class UserRegistrationView(BaseAPIView):
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]

    def post(self, request):
        try:
            email = request.data.get('email')
            password = request.data.get('password')
            phone_number = request.data.get('phone_number')
            first_name = request.data.get('first_name')
            last_name = request.data.get('last_name')

            success, response_data, status_code = AuthenticationService.register(
                email = email,
                password= password,
                phone_number=phone_number,
                first_name=first_name,
                last_name=last_name,
                request_meta=request.META,
                request=request
            )

            # create response object
            response = Response(standardized_response(**response_data), status = status_code)

            if success and status_code in (200, 201) and settings.JWT_COOKIE_SECURE:
                tokens = response_data.get('data', {}).get('tokens', {})
                if 'refresh_token' in tokens and 'refresh_expires_in' in tokens:
                    response.set_cookie(
                        key = settings.JWT_COOKIE_NAME,
                        value=tokens['refresh_token'],
                        expires= timezone.now() + timedelta(seconds=tokens['refresh_expires_in']),
                        secure=True,
                        httponly=True,
                        samesite='Strict',
                        path='/',
                        domain=settings.SESSION_COOKIE_DOMAIN
                    )

                # Set CSRF token
                if success:
                    get_token(request)
                return response
        except Exception as e:
            logger.error(f"Registration error: {str(e)}")
            logger.error(traceback.format_exc())
            return Response(standardized_response(success=False, error="Registration failed. Please try again."),status=status.HTTP_400_BAD_REQUEST)
        

class UserLoginView(BaseAPIView):
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]

    def post(self, request):
        try:
            email = request.data.get('email')
            password = request.data.get('password')
            device_info = request.data.get('device_info', {})

            success, response_data, status_code = AuthenticationService.login(
                email=email, 
                password=password,
                device_info= device_info,
                request_meta=request.META,
                request=request
            )

            # create response object
            response = Response(standardized_response(**response_data), status = status_code)

            if success and status_code in (200, 201) and settings.JWT_COOKIE_SECURE:
                tokens = response_data.get('data', {}).get('tokens', {})
                if 'refresh_token' in tokens and 'refresh_expires_in' in tokens:
                    response.set_cookie(
                        key = settings.JWT_COOKIE_NAME,
                        value=tokens['refresh_token'],
                        expires= timezone.now() + timedelta(seconds=tokens['refresh_expires_in']),
                        secure=True,
                        httponly=True,
                        samesite='Strict',
                        path='/',
                        domain=settings.SESSION_COOKIE_DOMAIN
                    )

                # Set CSRF token
                if success:
                    get_token(request)
                return response
        except Exception as e:
            logger.error(f"Login error: {str(e)}")
            logger.error(traceback.format_exc())
            return Response(standardized_response(success=False, error="An unexpected error occured. Please try again."),status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class TokenRefreshView(BaseAPIView):
    """Api endpoint for refreshing JWT tokens"""
    permission_classes = [AllowAny]
    throttle_classes = [AnonRateThrottle]

    def post(self, request):
        try:
            refresh_token = request.data.get('refresh_token')
            if not refresh_token and settings.JWT_COOKIE_SECURE:
                refresh_token = request.COOKIES.get(settings.JWT_COOKIE_NAME)
            
            success, response_data, status_code = AuthenticationService.refresh_token(refresh_token)

            response = Response(standardized_response(**response_data), status = status_code) # pyright: ignore[reportArgumentType]

            if success and status_code in (200, 201) and settings.JWT_COOKIE_SECURE:
                tokens = response_data["data"]                
                if "refresh_token" in tokens and "refresh_expires_in" in tokens: # pyright: ignore[reportOperatorIssue]
                    response.set_cookie(
                        key = settings.JWT_COOKIE_NAME,
                        value = tokens['refresh_token'], # pyright: ignore[reportArgumentType] # pyright: ignore[reportIndexIssue] # type: ignore
                        expires= timezone.now() + timedelta(seconds=tokens['refresh_expires_in']), # pyright: ignore[reportArgumentType] # pyright: ignore[reportIndexIssue] # type: ignore
                        secure=True,
                        httponly=True,
                        samesite='Strict',
                        path='/',
                        domain=settings.SESSION_COOKIE_DOMAIN
                    )

                # Set CSRF token
                if success:
                    get_token(request)
                return response
        
        except Exception as e:
            logger.error(f"Token refresh error: {str(e)}")
            logger.error(traceback.format_exc())
            return Response(standardized_response(success=False, error="An unexpected error occured during token refresh."),status=status.HTTP_500_INTERNAL_SERVER_ERROR)

