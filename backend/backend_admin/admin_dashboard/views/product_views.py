from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.pagination import PageNumberPagination
from django.forms import ValidationError
from django.db import transaction
import time

from ecommerce.models import Product
from inventory.services import InventoryService
from admin_dashboard.product_serializers import (ProductCreateSerializer, ProductDetailSerializer, ProductFullSerializer, ProductListSerializer, ProductImageSerializer, ProductVariantSerializers)

class AdminProductViewSet(viewsets.ModelViewSet):
    """ViewSet for managin products in the admin dashboard"""
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    permission_classes = [IsAdminUser]
    pagination_class = PageNumberPagination

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.inventory_service = InventoryService()


    def get_serializer_context(self):
        """Add request to serializer context"""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
