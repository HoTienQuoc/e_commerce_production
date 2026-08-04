from django.db import models
from datetime import timedelta
import uuid

class AnalyticsEvent(models.Model):
    EVENT_TYPES = [
        ('view', 'Product View'),
        ('card_view', 'Add to Cart'),
        ('cart_remove', 'Remove from Cart'),
        ('purchase', 'Purchase'),
        ('search', 'Search'),
        ('wishilist_add', 'Add to Wishlist'),
    ]
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey('authentication.CustomUser', on_delete=models.CASCADE)
    event_type = models.CharField(max_length=20, choices=EVENT_TYPES)
    product = models.ForeignKey('ecommerce.Product', on_delete=models.CASCADE, null=True)
    search_query = models.CharField(max_length=255, null=True)
    metadata = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [
            models.Index(fields=['event_type', 'created_at']),
            models.Index(fields=['user', 'created_at']),
        ]

class RevenueMetrics(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    date = models.DateField(db_index=True, unique=True)
    total_revenue = models.DecimalField(max_digits=10, decimal_places=2)
    order_count = models.IntegerField()
    average_order_value = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta: 
        ordering = ['-date']
        indexes = [
            models.Index(fields=['date']),
        ]

    @property
    def profit(self):
        return float(self.total_revenue)*0.3

    def __str__(self):
        return f"Revenue for {self.date}: {self.total_revenue}"

class AnalysticsSumary(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    date = models.DateField(unique=True)
    total_views = models.IntegerField(default=0)
    unique_visitors = models.IntegerField(default=0)
    conversion_rate = models.FloatField(default=0.0)
    bounce_rate = models.FloatField(default=0.0)
    avg_session_duration = models.DurationField(null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    