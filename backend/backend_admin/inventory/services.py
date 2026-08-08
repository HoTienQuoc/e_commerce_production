class InventoryService:
    """Service for managing inventory operations"""
    def initialize_inventory(self, product, initial_stock=0, update_if_exists=False):
        """Initialize inventory record for a product with atomic transaction support"""
        from .models import InventoryRecord, StockAdjustment
        from django.conf import settings
        from django.db import transaction

        # Set default values
        default_low_stock_threshold = getattr(settings, 'LOW_STOCK_THRESHOLD', 5)
        default_reorder_point = getattr(settings, 'DEFAULT_REORDER_POINT', 3)
        default_reorder_quantity = getattr(settings, 'DEFAULT_REORDER_QUANTITY', 10)

        with transaction.atomic():
            inventory, created = InventoryRecord.objects.get_or_create(product = product, defaults={
                'initial_stock': initial_stock,
                'current_stock': initial_stock,
                'low_stock_threshold': default_low_stock_threshold,
                'reorder_point': default_reorder_point,
                'reorder_quantity': default_reorder_quantity
            })

            if not created and update_if_exists and inventory.initial_stock != initial_stock:
                previous_stock = inventory.current_stock
                adjustment = initial_stock - previous_stock

                if adjustment != 0:
                    StockAdjustment.objects.create(
                        inventory = inventory,
                        quantity = adjustment,
                        previous_stock = previous_stock,
                        new_stock = initial_stock,
                        adjustment_type = 'inventory',
                        reason = 'Initial stock update',
                        reference = f"Product update: {product.id}"
                    )

                inventory.initial_stock = initial_stock
                inventory.save(update_fields = ['initial_stock'])

        return inventory, created

                
