from typing import Dict, Any, List
from datetime import datetime, timedelta
from django.utils import timezone
from django.db.models import Sum, Count, Avg, F, Q
from asgiref.sync import sync_to_async
from .core import MCPTool
from ecommerce.models import Order, OrderItem, Product
from authentication.models import CustomUser
from inventory.models import StockAdjustment, InventoryRecord
import logging

logger = logging.getLogger(__name__)

class EcommerceMCPTools:
    """MCP Tools for e-commerce operations"""
    @staticmethod
    def get_sales_analytics_tool()->MCPTool:
        return MCPTool(
            name="get_sales_analytics",
            description="Retrieve comprehensive sales analytics data including revenue, orders, and trends",
            inputSchema={
                "type": "object",
                "properties": {
                    "period": {
                        "type": "string",
                        "enum": [
                            "today", "7days", "30days", "90days", "1year"
                        ],
                        "description": "Time period for analysis",
                    },
                    "metrics": {
                        "type": "array",
                        "items": {
                            "type": "string",
                            "enum": ["revenue", "orders", "avg_order_value",
                            "top_products", "customer_segments"],
                        },
                        "description": "Specific metrics to include"
                    },
                    "group_by": {
                        "type": "string",
                        "enum": ["day", "week", "month", "category", "customer"],
                        "description": "How to group the data"
                    }
                },
                "required": ["period"]
            },
        )

    @staticmethod
    async def handle_sales_analytics(args: Dict[str, Any])->Dict[str, Any]:
        """Handle sales analytics tool call"""
        period = args.get("period", "30days")
        metrics = args.get("metrics", ["revenue", "orders", "avg_order_value"])
        group_by = args.get("group_by", "day")

        # Calculate data range
        end_date = timezone.now()

        if period == "today":
            start_date = end_date.replace(hour=0, minute=0, second=0, microsecond=0)
        elif period == "7days":
            start_date = end_date - timedelta(days=7)
        elif period == "90days":
            start_date = end_date - timedelta(days=90)
        elif period == "30days":
            start_date = end_date - timedelta(days=30)
        elif period == "1year":
            start_date = end_date - timedelta(days=365)
        else:
            start_date = end_date - timedelta(days=30)
        return await sync_to_async(EcommerceMCPTools._get_sales_data)(start_date, end_date, metrics, group_by)

