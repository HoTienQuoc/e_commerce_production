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

    