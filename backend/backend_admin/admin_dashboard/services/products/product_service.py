import logging
from django.db import transaction
from rest_framework import status
from rest_framework.exceptions import ValidationError
from ecommerce.models import Product
from inventory.models import InventoryRecord
from inventory.services import InventoryService
from admin_dashboard.product_serializers import (ProductFullSerializer, ProductUpdateSerializer, ProductVariantSerializers)
from .base_service import BaseService
from .product_cache_service import ProductCacheService
from .product_filter_service import ProductFilterService

logger = logging.getLogger(__name__)

class ProductService(BaseService):
    """Main service for product operations"""
    def __init__(self, request=None):
        super().__init__()
        self.request = request
        self.user = request.user if request else None

        # Initialize dependent services
        self.cache_service = ProductCacheService()
        self.filter_service = ProductFilterService()
        self.inventory_service = InventoryService()

        # For tracking current product ID in operations
        self.current_product_id = None

    def get_filtered_products(self, query_params):
        """Get filtered products using filter service"""
        return self.filter_service.get_filtered_products(query_params)

    def get_filter_options(self):
        """Get filter options using filter service"""
        return self.filter_service.get_filter_options()

    def clear_product_cache(self, product_id = None):
        """Clear product cache using cache service"""
        self.cache_service.clear_product_cache(product_id)

    

    
    