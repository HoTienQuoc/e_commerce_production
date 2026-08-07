from rest_framework import serializers
import uuid
import base64
from django.core.files.base import ContentFile
from django.utils.text import slugify
from ecommerce.models import (Product, Category, ProductImage, ProductVariant, ProductVariation, Order, OrderItem)
from inventory.models import InventoryRecord

class ProductImageSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = ProductImage
        fields = [
            'id', 'product', 'image', 'image_url', 'alt_text', 'order', 'is_primary', 'created_at'
        ]
        extra_kwargs = {
            'product': {'required':False}, 
            'image': {'required':False},
            'created_at': {'read_only':True}
        }

    def get_image_url(self, obj):
        if obj.image:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.image.urls)
            return obj.image.url
        return None

    def validate(self, data):
        return data


class ProductListSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    primary_image_url = serializers.SerializerMethodField()
    stock_status = serializers.SerializerMethodField()
    stock = serializers.IntegerField(read_only=True)

    def get_stock_status(self, obj):
        inventory = getattr(obj, 'inventory', None)
        return inventory.stock_status if inventory else 'unknown'

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'category', 'category_name', 'price', 'stock', 'discount_price', 'display_price', 'rating', 'primary_image_url', 'stock_status', 'is_active'
        ]

    def get_primary_image_url(self, obj):
        request = self.context.get('request')
        primary = obj.primary_image

        if primary and primary.image:
            if request:
                return request.build_absolute_uri(primary.image.url)
            return primary.image.url
        return None

    def to_representation(self, instance):
        ret = super().to_representation(instance)
        if self.context.get('include_all_images', False):
            ret['all_image_urls'] = self.get_all_image_urls(instance) # pyright: ignore[reportAttributeAccessIssue]
        return ret

    
    
    