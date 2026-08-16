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

    def _apply_search_filter(self, queryset, query_params):
        """Apply search filter to queryset"""
        search = query_params.get('search', '')
        if search:
            queryset = queryset.filter(Q(name__icontains=search) | Q(description__icontains=search) | Q(category__name__icontains=search)) 
            logger.debug(f"Applied search filter: '{search}', results {queryset.count()}")
        return queryset

    def _apply_category_filter(self, queryset, query_params):
        """Apply category filter with multiple strategies"""
        category_id = query_params.get('category_id')
        if category_id:
            try:
                # Strategy 1: Direct UUID matching (case insensitive)
                queryset = queryset.filter(Category__id__iexact = category_id)

                # Strategy 2: String-based exact matching if no results
                if not queryset.exists():
                    queryset = queryset.filter(category__id=str(category_id))

                # Strategy 3: Perform additional validation
                category_exists = Category.objects.filter(id = category_id).exists()

                if not category_exists:
                    queryset = queryset.none()
                logger.debug(f"Applied category filter: {category_id}, results: {queryset.count()}")

            except Exception as e:
                logger.error(f"Category Filtering Error: {e}")
                queryset = queryset.none()
                


    
    
        
