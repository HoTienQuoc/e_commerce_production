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

    @staticmethod
    def _get_sales_data(start_date, end_date, metrics, group_by)->Dict[str, Any]:
        """Get sales data with property field access"""
        try:
            orders_qs = Order.objects.filter(created_at__gte = start_date, created_at__lte = end_date).select_related('user').prefetch_related('items_product')
            result: Dict[str, Any] = {
                "period": f"{start_date.isoformat()} to {end_date.isoformat()}",
                "total_records": orders_qs.count()
            }
            if "revenue" in metrics:
                revenue_data = orders_qs.aaggregate(total_revenue=Sum('total_amount'), avg_order_value = Avg('total_amount'))
                result["revenue"] = {
                    "total": float(revenue_data.get('total_revenue', 0) or 0), # pyright: ignore[reportAttributeAccessIssue]
                    "average_order_value": float(revenue_data.get('avg_order_value', 0) or 0) # pyright: ignore[reportAttributeAccessIssue]
                }
            if "orders" in metrics:
                result["order"] = {
                    "total": orders_qs.count(),
                    "completed": orders_qs.filter(status = 'completed').count(),
                    "processing": orders_qs.filter(status = 'processing').count(),
                    "in_transit": orders_qs.filter(status = 'in_transit').count(),
                    "on_hold": orders_qs.filter(status = 'on_hold').count(),
                    "rejected": orders_qs.filter(status = 'rejected').count(),
                }
            if "top_products" in metrics:
                top_products = OrderItem.objects.filter(
                    order__created_at__gte = start_date, 
                    order__created_at__lte = end_date).values(
                        'product__name', 
                        'product__id').annotate(
                            total_sold = Sum('quantity'), 
                            total_revenue = Sum(F('quantity') * F('price'))).order_by('-total_revenue')[:10]
                result["top_products"] = [
                    {
                        "id": item['product__id'],
                        "name": item['product__name'],
                        "quantity_sold": item['total_sold'],
                        "revenue": float(item['total_revenue'])
                    } for item in top_products
                ]
            if "customer_segments" in metrics:
                customer_stats = orders_qs.values('user__id', 'user__username').annotate(orders_count = Count('id'), total_spent = Sum('total_amount')).order_by('-toal_spent')[:20]
                result["top_customers"] = [
                    {
                        "user_id": item['user__id'],
                        "username": item['user__username'],
                        "order_count": item['order_count'],
                        "total_spent": float(item['total_spent'])
                    } for item in customer_stats
                ]
            return result
        except Exception as e:
            logger.error((f"Error in _get_sales_data: {str(e)}"))
            return {
                "error": str(e),
                "period": f"{start_date.isoformat()} to {end_date.isoformat()}",
                "total_records": 0,
            }


