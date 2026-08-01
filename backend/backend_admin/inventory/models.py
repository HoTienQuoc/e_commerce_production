from django.db import models
import uuid
from django.conf import settings
from django.db.models import F, Sum, Count
from ecommerce.models import Product, Order
from django.utils import timezone
from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from django.db import transaction

class InventoryRecord(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    product = models.OneToOneField(Product, on_delete=models.CASCADE, related_name='inventory')
    initial_stock = models.IntegerField(default=0, help_text="Starting stock level - never changes after creation")
    current_stock = models.IntegerField(default=0, help_text="Current available stock - changes with adjustments")
    low_stock_threshold = models.IntegerField(null=True, blank=True, default=5)
    reorder_point = models.IntegerField(null=True, blank=True, default=3)
    reorder_quantity = models.IntegerField(null=True, blank=True, default=10)
    last_updated = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            models.Index(fields=['current_stock']),
            models.Index(fields=['product']),
        ]

    def save(self, *args, **kwargs):
        """Override save to clear cache when inventory changes"""
        is_new = self._state.adding
        super().save(*args, **kwargs)

    @property
    def stock_status(self):
        """Return the stock status based on thresholds"""
        if self.current_stock <= 0:
            return 'out_of_stock'
        threshold = self.low_stock_threshold or getattr(settings, 'LOW_STOCK_THRESHOLD', 5)
        if self.current_stock <= threshold:
            return 'low_stock'
        return 'in_stock'

    @property
    def sold_percentage(self):
        """Return percentage of initial stock sold"""
        if self.initial_stock > 0:
            sold = self.initial_stock - self.current_stock
            return round((max(0, sold) / self.initial_stock)*100, 2)
        return 0.0

    @property
    def 