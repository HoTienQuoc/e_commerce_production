from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.pagination import PageNumberPagination
from django.forms import ValidationError
from django.db import transaction
import time
import logging

from ecommerce.models import Product
from inventory.services import InventoryService
from admin_dashboard.product_serializers import (ProductCreateSerializer, ProductUpdateSerializer, ProductDetailSerializer, ProductFullSerializer, ProductListSerializer, ProductImageSerializer, ProductVariantSerializers)
from admin_dashboard.services.products.product_service import ProductService
from admin_dashboard.services.image_service import ImageService
from admin_dashboard.core.cache_util import CacheUtil

logger = logging.getLogger(__name__)

class AdminProductViewSet(viewsets.ModelViewSet):
    """ViewSet for managin products in the admin dashboard"""
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    permission_classes = [IsAdminUser]
    pagination_class = PageNumberPagination

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.inventory_service = InventoryService()
        self.product_service = ProductService()
        self.image_service = ImageService()
        self.cache_util = CacheUtil(model_name='product')


    def get_serializer_context(self):
        """Add request to serializer context"""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def get_queryset(self):
        return self.product_service.get_filtered_products(self.request.query_params) # pyright: ignore[reportAttributeAccessIssue]

    def get_serializer_class(self):
        """Return the approriate serializer class based on the action"""
        if self.action == 'create':
            return ProductCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return ProductUpdateSerializer
        elif self.action == 'list':
            return ProductListSerializer
        elif self.action == 'retrieve':
            return ProductFullSerializer
        return super().get_serializer_class()

    def create(self, request, *args, **kwargs):
        try:
            data = request.data.copy()

            if 'stock' in data and not data.get('initial_stock'):
                data['initial_stock'] = data['stock']

            # Create product with serializer
            serializer = self.get_serializer(data=data)
            serializer.is_valid(raise_exception=True)

            with transaction.atomic():
                product = serializer.save()
                # Process images if provided in request
                image_files = self.image_service.extract_files_from_request(request)

                if image_files:
                    created_images = self.image_service.process_images(product, image_files)
                else:
                    logger.warning('No image files found in request')
            # Clear all product caches
            self.product_service.clear_product_cache()
            self._clear_related_caches(product.id)

            product = Product.objects.get(id=product.id)
            return Response(
                ProductFullSerializer(product, context = self.get_serializer_context()).data,
                status=status.HTTP_201_CREATED
            )

        except ValidationError as e:
            return Response({
                'error': 'Validation error',
                'details': str(e)
            }, status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            import traceback
            logger.error(f"Error creating product: {str(e)}")
            logger.debug(traceback.format_exc())
            return Response({
                'error': 'Server error',
                'details': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



    def _clear_related_caches(self, product_id):
        """Clear all caches related to a product update"""
        from django.core.cache import cache
        filter_patterns = [
            'product_*_query_*',
            'category_*_products_*',
            'inventory_*',
            'product_stats_*'
        ]

        if hasattr(cache, '_cache') and hasattr(cache._cache, 'get_client'): # pyright: ignore[reportAttributeAccessIssue]
            try:
                redis_client = cache._cache.get_client() # pyright: ignore[reportAttributeAccessIssue]
                for pattern in filter_patterns:
                    cursor = 0
                    while True:
                        cursor, keys = redis_client.scan(cursor=cursor, match=pattern, count=100)

                        if keys:
                            redis_client.delete(*keys)
                        if cursor == 0:
                            break
            except Exception:
                common_keys = [
                    'product_filters', 'category_list', 'inventory_summary', f'product_{product_id}_related', f'product_{product_id}_stats'
                ]
                cache.delete_many(common_keys)
        cache.set('cache_invalidated_at', time.time(), timeout=3600)
