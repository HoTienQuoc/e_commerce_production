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

    def update_inventory_from_variants(self, product, total_stock, is_sync = False, adjustment_type=None, notes = None):
        """Update inventory record based on variant stocks"""
        inventory = getattr(product, 'inventory', None)
        # if no inventory exists, create one
        if not inventory:
            return self.initialize_inventory(product, total_stock)

        # skip if no change in stock
        if inventory.current_stock == total_stock:
            return inventory

        # Determine the adjustment type if not provided
        if adjustment_type is None:
            adjustment_type = 'sync' if is_sync else 'inventory'

        # Create approriate message based on adjustment type
        if notes is None:
            if adjustment_type == 'redistribution':
                notes = 'Stock redistribution across variants'
            elif adjustment_type == 'sync':
                notes = 'Synchronized stock with variants'
            else:
                notes = 'Stock updated from variants'

        # Create an inventory log entry
        from .models import InventoryLog, StockAdjustment

        # Log the inventory change 
        InventoryLog.objects.create(
            product = product,
            previous_stock = inventory.current_stock,
            current_stock = total_stock,
            adjustment_type = adjustment_type,
            notes = notes
        )

        # Create a stock adjustment record
        StockAdjustment.objects.create(
            inventory = inventory,
            quantity = total_stock - inventory.current_stock,
            adjustment_type = adjustment_type,
            reason = notes,
            previous_stock = inventory.current_stock,
            new_stock = total_stock,
            reference = f'{adjustment_type.capitalize()}: {product.id}'
        )

        # Update the inventory record
        inventory.current_stock = total_stock
        inventory.save(update_fields = ['current_stock'])

        return inventory


    