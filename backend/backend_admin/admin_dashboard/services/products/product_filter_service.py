import json
import logging
from django.db.models import Q, F
from django.core.exceptions import FieldError
from ecommerce.models import Product, Category
from rest_framework.response import Response
from rest_framework import status
from .base_service import BaseService
from .product_cache_service import ProductCacheService

logger = logging.getLogger(__name__)

class ProductFilterService(BaseService):
    """Service for handling product filtering operations"""
    def __init__(self) -> None:
        super().__init__()
        self.cache_service = ProductCacheService()

    def get_filtered_products(self, query_params):
        """Get filtered products with robust parameter handling"""
        # Log incoming parameters for debugging
        logger.debug(f"Filtering parameters: {json.dumps(query_params, default=str)}")

        # Use cache service to get or generate queryset
        return self.cache_service.get_cached_queryset(query_params, lambda: self._build_filtered_queryset(query_params))

    def _build_filtered_queryset(self, query_params):
        """Build filtered product queryset based on query parameters"""
        # Select approriate query strategy
        queryset = self._get_base_queryset(query_params)

        # Apply filters in sequence
        queryset = self._apply_search_filter(queryset, query_params)
        queryset = self._apply_category_filter(queryset, query_params)
        queryset = self._apply_stock_status_filter(queryset, query_params)
        queryset = self._apply_price_filter(queryset, query_params)
        queryset = self._apply_storing(queryset, query_params)

        logger.debug(f"Final result count: {queryset.count()}")
        return queryset

    def _get_base_queryset(self, query_params):
        """Get base queryset with approriate selects and perfetches"""
        if query_params.get('loadBasicInfo')=='true':
            return Product.objects.only('id', 'name', 'price', 'discount_price', 'is_active', 'category__name', 'category__id', 'created_at').select_related('category')
        else:
            return Product.objects.select_related('category', 'inventory').prefetch_related('images', 'variants', 'variation_types')

    
        
