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

    def get_agent_type_display(self):
        """"""


class AgentExecution(models.Model):
    """Track agent executions and results"""
    EXECUTION_STATUS = [
        ('pending', 'Pending'),
        ('running', 'Running'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('cancelled', 'Cancelled'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    agent = models.ForeignKey(Agent, on_delete=models.CASCADE, related_name='executions')
    status = models.CharField(max_length=20, choices=EXECUTION_STATUS, default='pending')
    input_data = models.JSONField(default=dict)
    output_data = models.JSONField(default=dict)
    error_message = models.TextField(blank=True)
    execution_time = models.FloatField(null=True, help_text="Execution time in seconds")
    started_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-started_at']

class ChatSession(models.Model):
    """Chat session model to group related messages"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    session_id = models.CharField(max_length=100, unique=True, db_index=True)
    user = models.ForeignKey('authentication.CustomUser', on_delete=models.CASCADE, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    # Session metadata
    metadata = models.JSONField(default=dict, blank=True)
    is_active = models.BooleanField(default=True)

    # Session managemnet fields
    title = models.CharField(max_length=200, blank=True, help_text="User-defined session title")
    last_activity = models.DateTimeField(auto_now=True, db_index=True)
    is_archived = models.BooleanField(default=True)
    archived_at = models.DateTimeField(null=True, blank=True)

    # Session settings
    context_window_size = models.IntegerField(default=10, help_text="Number of previous messages to include in context")

    class Meta:
        ordering = ['-last_activity']
        indexes = [
            models.Index(fields=['user', '-last_activity']),
            models.Index(fields=['session_id']),
            models.Index(fields=['is_active', '-last_activity']),
            models.Index(fields=['is_archived', '-last_activity']),
            models.Index(fields=['user', 'is_active', '-last_activity']),
        ] 

    def __str__(self):
        return f"Chat Session {self.session_id} - {self.user.username}"

    @property
    def message_count(self):
        """Get total message count for this session"""
        return self.messages.filter(is_deleted=False).count() # pyright: ignore[reportAttributeAccessIssue]

    def get_context_messages(self):
        """Get recent messages for AI context"""
        return self.messages.filter( # pyright: ignore[reportAttributeAccessIssue]
            is_deleted = False
        ).order_by('-created_at')[:self.context_window_size]

    def mark_inactive(self):
        """Mark session as inactive"""
        self.is_active = False
        self.save(update_fields=['is_active', 'updated_at'])