from django.db import models
from django.contrib.contenttypes.models import ContentType
from django.contrib.contenttypes.fields import GenericForeignKey
from django.conf import settings
import uuid
import json

from .services.chat_agent import QueryIntent

class Agent(models.Model):
    """Core agent model that defines different AI agents"""
    AGENT_TYPES = [
        ('inventory_manager', 'Inventory Management Agent'),
        ('sales_analyst', 'Sales Analysis Agent'),
        ('customer_insights', 'Customer Insights Agent'),
        ('pricing_optimizer', 'Pricing Optimization Agent'),
        ('marketing_strategist', 'Marketing Strategy Agent'),
        ('supply_chain', 'Supply Chain Agent'),
        ('fraud_detector', 'Fraud Detection Agent'),
        ('chat_agent', 'Chat Assistant Agent'),
        ('recommendation_engine', 'Recommendation Engine')
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=True)
    name = models.CharField(max_length=100)
    agent_type = models.CharField(max_length=50, choices=AGENT_TYPES)
    description = models.TextField()
    is_active = models.BooleanField(default=True)
    configuration = models.JSONField(default = dict)
    last_execution = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    total_executions = models.IntegerField(default=0)
    successful_executions = models.IntegerField(default=0)
    avg_execution_time = models.FloatField(default=0.0)
    last_error = models.TextField(blank=True)

    def success_rate(self):
        """Calculate success rate percentage"""
        if self.total_executions == 0:
            return 0.0
        return (self.successful_executions / self.total_executions)*100

    def __str__(self):
        return f"{self.name} ({self.get_agent_type_display()})"