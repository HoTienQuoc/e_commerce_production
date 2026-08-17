import os
import base64
from io import BytesIO
from django.core.files.uploadedfile import InMemoryUploadedFile, UploadedFile
from django.core.files.base import ContentFile
from rest_framework.response import Response
from rest_framework import status
from ecommerce.models import ProductImage, Product
from admin_dashboard.product_serializers import ProductImageSerializer

class ImageService:
    def extract_files_from_request(self, request):
        """Extract image files from both multipart and base64 data"""
        image_files = []
        primary_image_index = None

        # Get primary image index if provided
        if hasattr(request.data, 'get'):
            primary_image_index = request.data.get('primary_image_index')
            if primary_image_index and str(primary_image_index).isdigit():
                primary_image_index = int(primary_image_index)

        if not image_files and hasattr(request, 'FILES'):
            images_field = request.FILES.getlist('images')
            for i, file_obj in enumerate(images_field):
                try:
                    is_primary = primary_image_index is not None and i == primary_image_index
                    file_name = file_obj.name
                    base_name = os.path.splitext(file_name)[0]
                    alt_text = base_name.replace('_', '')

                    image_files.append({
                        'file': file_obj,
                        'alt_text': alt_text,
                        'order': 1,
                        'is_primary': is_primary,
                        'name': file_name
                    })

                except Exception as e:
                    pass

        # Sort by order/index
        image_files.sort(key=lambda x:x['order'])

        if image_files and primary_image_index is None:
            image_files[0]['is_primary'] = True

        return image_files

    def process_images(self, product, image_data_list):
        """Process and save uploaded image files"""
        created_images = []

        for i, image_data in enumerate(image_data_list):
            try:
                if 'file' in image_data and image_data['file']:
                    file_obj = image_data['file']

                    image = ProductImage.objects.create(
                        product=product,
                        image=file_obj,
                        alt_text = image_data.get('alt_text', image_data.get('name', product.name)),
                        order=image_data.get('order', i),
                        is_primary = image_data.get('is_primary', False)
                    )

                    created_images.append(image)
                else:
                    continue

            except Exception as e:
                import traceback
                print(traceback.format_exc())

        # Ensure at least one image is primary if we have images
        if created_images and not any(img.is_primary for img in created_images):
            created_images[0].is_primary = True
            created_images[0].save(update_fields = ['is_primary'])

        return created_images
