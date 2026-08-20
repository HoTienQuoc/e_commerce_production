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

                # Process variants if provided
                if 'variants' in data:
                    # Get serializer class for validation
                    from admin_dashboard.product_serializers import ProductUpdateSerializer, ProductVariantSerializer, ProductFullSerializer

                    # Validate variants data
                    serializer = ProductUpdateSerializer(context = serializer_context)
                    validated_variants = serializer.validate_variants(data['variants'])  # pyright: ignore[reportAttributeAccessIssue]

                    # Process variants based on operation type


    def _process_variations(self, product, variations_data):
        """Process variation types for a product"""
        # Convert to standardized format
        if isinstance(variations_data, list):
            variations_dict = {}
            for variation in variations_data:
                if isinstance(variation, dict) and 'name' in variation and 'values' in variation:
                    variations_dict[variation['name']] = variation['values']
        variations_data = variations_dict
        # Delete variations not in new data
        existing_variations_names = set(product.variation_types.values_list('name', flat=True))

        # [('Color',), ('Size',)] - without flat = True
        # ['Color', 'Size']

        new_variations_names = set(variations_data.keys())
        to_delete = existing_variations_names - new_variations_names

        if to_delete:
            product.variation_types.filter(name__in = to_delete).delete()

        # Update or create variations
        for name, values in variations_data.items():
            ProductVariation.objects.update_or_create(
                product=product,
                name=name,
                defaults={'values': values}
            )

    def _process_variants(self, product, validated_variants, is_discount_update, is_stock_distribution, serializer_context):
        """Process variants based on operation type"""
        from admin_dashboard.product_serializers import ProductVariantSerializer

        # Get existing variants for reference
        existing_variants = {
            str(v.id): v for v in product.variants.all()
        }

        # Track processed variants and calculate total stock
        processed_ids = set()
        total_stock = 0

        # Get current total stock if this is a distribution
        current_inventory = getattr(product, 'inventory', None)
        current_total_stock = current_inventory.current_stock if current_inventory else 0

        for variant_data in validated_variants:
            variant = existing_variants[variant_data]
            old_stock = variant.stock

            if is_discount_update:
                self._update_variant_discount(variant, variant_data)

