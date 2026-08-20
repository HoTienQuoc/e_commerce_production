import logging
from django.db import transaction
from django.db.models import Sum
from rest_framework import serializers, status
from rest_framework.response import Response
from ecommerce.models import ProductVariant, ProductVariation
from inventory.models import VariantStockLog
from inventory.services import InventoryService
from .base_service import BaseService
from .product_cache_service import ProductCacheService

logger = logging.getLogger(__name__)

class ProductVariantService(BaseService):
    """Service for handling product operations"""
    def __init__(self, user=None):
        super().__init__()
        self.user = user
        self.cache_service = ProductCacheService()
        self.inventory_service = InventoryService()

    def manage_variants(self, product, data, serializer_context = None):
        """Manage variants and variations for a product"""
        try:
            self.cache_service.clear_product_cache(product.id)
            # Check operation types
            is_stock_distribution = data.get('is_stock_distribution', False)
            is_discount_update = data.get('is_discount_update', False)

            with transaction.atomic():
                # Process variations if needed
                if 'variations' in data and not is_discount_update and not is_stock_distribution:
                    self._process_variations(product, data['variations'])

    def _process_variations(self, product, data):
