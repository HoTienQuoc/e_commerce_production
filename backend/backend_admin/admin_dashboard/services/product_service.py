import logging
from django.db import transaction
from rest_framework import status
from rest_framework.exceptions import ValidationError
from ecommerce.models import Product
from inventory.models import InventoryRecord
from inventory.services import InventoryService
from admin_dashboard.product_serializers import (ProductFullSerializer, ProductUpdateSerializer, ProductVariantSerializers)
from .base_service import BaseService

logger = logging.getLogger(__name__)

class ProductService(BaseService):
    """Main service for product operations"""
    def __init__(self, request=None):
        super().__init__()
        self.request = request
        self.user = request.user if request else None

        # For tracking current product ID in operations
        self.current_product_id = None

    def get_filtered_products(self, query_params):
        """Get filtered products using filter service"""
        return self.filter_service.get_filtered_products(query_params)
    