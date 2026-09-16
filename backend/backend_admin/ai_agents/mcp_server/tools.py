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

    @staticmethod
    def get_inventory_status_tool()->MCPTool:
        return MCPTool(
            name="get_inventory_status",
            description="Get real-time inventory status including stock levels, alerts and recommendations",
            inputSchema={
                "type": "object",
                "properties": {
                    "product ids": {
                        "type": "array",
                        "items": {
                            "type": "integer"
                        },
                        "description": "Specific product IDs to check"
                    },
                    "category": {
                        "type": "string",
                        "description": "Filter by product category"
                    },
                    "alert_level": {
                        "type": "string",
                        "enum": ["low_stock", "out_of_stock", "in_stock", "overstocked", "all"],
                        "description": "Type of inventory alerts to include"
                    },
                    "include_recommendations": {
                        "type": "bool",
                        "description": "Whether to include restock recommendations"
                    }
                }
            }
        )

    @staticmethod
    async def handle_inventory_status(args: Dict[str, Any]) -> Dict[str, Any]:
        """Handle inventory status tool call"""
        product_ids = args.get('product_ids')
        category = args.get("category")
        alert_level = args.get("alert_level", "all")
        include_recommendations = args.get("include_recommendations", False)

        return await sync_to_async(EcommerceMCPTools._get_inventory_data)(product_ids, category, alert_level, include_recommendations)

    @staticmethod
    def _get_inventory_data(product_ids, category, alert_level, include_recommendations) -> Dict[str, Any]:
        """Get inventory data with proper model relationships"""
        try:
            products_qs = Product.objects.select_related('category')
            if product_ids:
                products_qs = products_qs.filter(id__in = product_ids)
            if category:
                products_qs = products_qs.filter(category__name__icontains=category)
            inventory_records = InventoryRecord.objects.filter(product__in = products_qs).select_related('product', 'product__category')

            alerts = []

            if alert_level in ["low_stock", "all"]:
                low_stock_items = inventory_records.filter(current_stock__lte = F('low_stock_threshold'), current_stock__gt = 0)
                alerts.extend([
                    {
                        "type": "low_stock",
                        "product_id": str(inv.product.id),
                        "product_name": inv.product.name,
                        "current_stock": inv.current_stock,
                        "threshold": inv.low_stock_threshold,
                        "category": inv.product.category.name if inv.product.category else None
                    } for inv in low_stock_items
                ])

            if alert_level in ["out_of_stock", "all"]:
                out_of_stock_items = inventory_records.filter(current_stock = 0)
                alerts.extend([
                    {
                        "type": "out_of_stock",
                        "product_id": str(inv.product.id),
                        "product_name": inv.product.name,
                        "current_stock": 0,
                        "threshold": inv.low_stock_threshold,
                        "category": inv.product.category.name if inv.product.category else None
                    } for inv in low_stock_items
                ])
            inventory_stats = inventory_records.aaggregate(total_products = Count('id'), total_stock_value = Sum(F('current_stock') * F('product__cost')))
            result = {
                "summary" : {
                    "total_products": inventory_stats.get('total_products', 0), # pyright: ignore[reportAttributeAccessIssue]
                    "total_stock_value": float(inventory_stats.get('total_stock_value', 0) or 0), # pyright: ignore[reportAttributeAccessIssue]
                    "alert_count": len(alerts)
                },
                "alerts": alerts
            }
            if include_recommendations:
                recommendations = []
                for alert in alerts:
                    if alert['type'] in ['low_stock', 'out_of_stock']:
                        try:
                            inventory = InventoryRecord.objects.get(product__id = alert['product_id'])
                            recommendations.append({
                                "product_id": alert['product_id'],
                                "product_name": alert['product_name'],
                                "recommended_quantity": inventory.reorder_quantity,
                                "estimated_cost": float(inventory.product.cost * inventory.reorder_quantity),
                                "priority": "high" if alert['type'] == 'out_of_stock' else "medium"
                            })
                        except InventoryRecord.DoesNotExist:
                            continue
                result["recommendations"] = recommendations
            return result
        except Exception as e:
            logger.error(f"Error in _get_inventory_data: {str(e)}")
            return {
                "error": str(e),
                "summary": {
                    "total_products":0, 
                    "total_stock_value": 0, 
                    "alert_count": 0
                },
                "alerts": []
            }

    


