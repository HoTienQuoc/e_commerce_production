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
    
    @staticmethod
    def update_profile(user, data, files = None, request = None):
        """Update user profile data"""
        try:
            if files and 'profile_picture' in files:
                ProfileService._process_profile_picture_file(user, files['profile_picture'])
            
            elif 'image_data' in data:


    @staticmethod
    def _proccess_image_data(user, image_data):
        """Proccess base64 image data"""
        try:
            # Try to parse as JSON array first 
            try:
                image_list = json.loads(image_data)
                if isinstance(image_data, list) and len(image_list) > 0:
                    image_info = image_list[0]
                    data_url = image_info.get('data')
                
                else:
                    data_url = f"data:image/jpeg;base64, {image_data}"
            except json.JSONDecodeError:
                dat_url = f"data:image/jpeg;base64, {image_data}"
            
            # Proccess the data_url
            if ';base64' in data_url:
                format_part, imgstr = data_url.split(';base64')

                # Extract file extension, default to jpeg
                try:
                    ext = format_part.split('/')[-1].lower()
                    if ext not in ['jpeg', 'jpg', 'png', 'gif', 'webp']:
                        ext = 'jpeg'
                except:
                    ext = 'jpeg'

                # create a contentFile from decoded base64
                data = ContentFile(base64.b64decode(imgstr), name=f"profile_{user.id}.{ext}")

                if user.profile_picture:
                    try:
                        if os.path.isfile(user.profile_picture.path):
                            os.remove(user.profile_picture.path)
                    except (ValueError, OSError) as e:
                        logger.warning(f"Could not remove old profile picture: {e}")
                
                user.profile_picture = data
                user.save(update_fields = ['profile_picture'])

                logger.info(f"Profile picture updated from base64 for user {user.id}")
                return True
            
            else:
                raise ValueError("Invalid image data format - missing base64 prefix")
            
        except Exception as e:
            logger.error(f"Error proccessing image data {str(e)}")
            raise

                

    @staticmethod
    def _process_profile_picture_file(user, file):
        """Process uploaded profile picture file"""
        if user.profile_picture:
            try:
                if os.path.isfile(user.profile_picture.path):
                    os.remove(user.profile_picture.path)
            except (ValueError, OSError) as e:
                logger.warning(f"Could not remove old profile picture: {e}")
            
        # set new profile picture
        user.profile_picture = file
        user.save(update_fields = ['profile_picture'])

        logger.info(f"Profile picture updated for user {user.id}")
        return True
