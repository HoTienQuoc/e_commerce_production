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
from admin_dashboard.product_serializers import (ProductCreateSerializer, ProductUpdateSerializer, ProductDetailSerializer, ProductFullSerializer, ProductListSerializer, ProductImageSerializer, ProductVariantSerializers)
from admin_dashboard.services.products.product_service import ProductService
from admin_dashboard.core.cache_util import CacheUtil

class AdminProductViewSet(viewsets.ModelViewSet):
    """ViewSet for managin products in the admin dashboard"""
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    permission_classes = [IsAdminUser]
    pagination_class = PageNumberPagination

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.inventory_service = InventoryService()
        self.product_service = ProductService()
        self.cache_util = CacheUtil(model_name='product')


    def get_serializer_context(self):
        """Add request to serializer context"""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def get_queryset(self):
        return self.product_service.get_filtered_products(self.request.query_params) # pyright: ignore[reportAttributeAccessIssue]

    def get_serializer_class(self):
        """Return the approriate serializer class based on the action"""
        if self.action == 'create':
            return ProductCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return ProductUpdateSerializer
        elif self.action == 'list':
            return ProductListSerializer
        elif self.action == 'retrieve':
            return ProductFullSerializer
        return super().get_serializer_class()

    def create(self, request, *args, **kwargs):
        try:
            data = request.data.copy()

            if 'stock' in data and not data.get('initial_stock'):
                data['initial_stock'] = data['stock']

            # Create product with serializer
            serializer = self.get_serializer(data=data)
            serializer.is_valid(raise_exception=True)

            with transaction.atomic():
                product = serializer.save()
                
        return super().create(request, *args, **kwargs)