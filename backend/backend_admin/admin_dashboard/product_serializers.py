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

class ProductVariantSerializers(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = ProductVariant
        fields = [
            'id', 'product', 'attributes', 'sku', 'price', 'discount_price', 'stock', 'image', 'image_url', 'created_at', 'updated_at'
        ]
        extra_kwargs = {
            'product': {'required':False},
            'created_at': {'read_only': True},
            'updated_at': {'read_only': True},
            'image': {'required':False, 'write_only':True}
        }

    def get_image_url(self, obj):
        if obj.image:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.image.urls)
            return obj.image.url
        return None

    def save(self, **kwargs):
        instance = super().save(**kwargs)
        # clear related product cache upon variant save
        return instance

    def validate(self, data):
        if 'price' in data and data['price'] is not None:
            product = data.get('product') or self.instance.product if self.instance else None

            if product and data['price'] > product.price and not getattr(product, 'allow_price_increase', False):
                raise serializers.ValidationError({"price": "Variant price cannot exceed base product price unless explicitly allowed"}) 

            if 'discount_price' in data and data['discount_price'] is not None:
                price = data.get('price')
                if price and data['discount_price'] >= price:
                    raise serializers.ValidationError({"discount_price":"Discount price must be lower than regular price"})

            request = self.context.get('request')
            if request and request.data.get('is_stock_distribution'):
                return data
            return data

class ProductVariationSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductVariation
        fields = [
            'id', 'name', 'values', 'created_at', 'updated_at'
        ]
        extra_kwargs = {
            'created_at': {'read_only': True},
            'updated_at': {'read_only': True},
        }



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

class ProductDetailSerializer(ProductListSerializer):
    profit_margin = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = ProductListSerializer.Meta.fields + ['description', 'cost', 'profit_margin', 'review_count', 'created_at', 'updated_at']

    def get_profit_margin(self, obj):
        if obj.price and obj.cost and obj.cost > 0:
            actual_price = obj.discount_price if obj.discount_price else obj.price
            margin = ((actual_price - obj.cost)/obj.price)*100
            return round(margin,2)
        return None

class ProductFullSerializer(ProductDetailSerializer):
    images = ProductImageSerializer(many=True, read_only=True)
    variants = ProductVariationSerializer(many=True)
    variations = serializers.SerializerMethodField()
    inventory = serializers.SerializerMethodField()
    initial_stock = serializers.IntegerField(source='inventory.initial_stock', read_only=True)
    current_stock = serializers.IntegerField(source='inventory.current_stock', read_only=True)

    class Meta:
        model = Product
        fields = ProductDetailSerializer.Meta.fields + ['images', 'variants', 'variations', 'inventory', 'initial_stock', 'current_stock']

    def get_variations(self, obj):
        variations = {}
        for variation in obj.vatiation_types.all():
            variations[variation.name] = variation.values
        if not variations:
            for variant in obj.variants.all():
                for key, value in variant.attributes.items():
                    if key not in variations:
                        variations[key] = []
                    if value not in variations[key]:
                        variations[key].append(value)
        return variations

    def get_inventory(self, obj):
        inventory = getattr(obj, 'inventory', None)
        if inventory:
            return InventorySerializer(inventory).data
        return None




class InventorySerializer(serializers.ModelSerializer):
    sold_count = serializers.IntegerField(read_only=True)
    sold_percentage = serializers.FloatField(read_only=True)
    stock_status = serializers.CharField(read_only=True)

    class Meta:
        model = InventoryRecord
        fields = [
            'id', 'initial_stock', 'current_stock', 'low_stock_threshold', 'reorder_point', 'reorder_quantity', 'last_updated', 'sold_count', 'sold_percentage', 'stock_status'
        ]
        read_only_fields = [
            'id', 'last_updated', 'current_stock'
        ]


class ProductCreateSerializer(serializers.ModelSerializer):
    images = ProductImageSerializer(many=True, required=False)
    variations = ProductVariationSerializer(many=True, required=True, source='variations_type')
    variants = ProductVariantSerializers(many=True, required=False)
    initial_stock = serializers.IntegerField(write_only=True, required=False, default=0)
    low_stock_threshold = serializers.IntegerField(required=False, allow_null=True)
    reorder_point = serializers.IntegerField(required=False, allow_null=True)
    reorder_quantity = serializers.IntegerField(required=False, allow_null=True)

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'category', 'price', 'discount_price', 'cost', 'is_active', 'images', 'variations', 'variants',
            'initial_stock', 'low_stock_threshold', 'reorder_point', 'reorder_quantity'
        ]

    def valiate(self, data):
        discount_price = data.get('discount_price')
        price = data.get('price')
        cost = data.get('cost')

        if discount_price and price and discount_price >= price:
            raise serializers.ValidationError({"discount_price": "Must be less than regular price"})

        if price and cost and price < cost:
            raise serializers.ValidationError({"price": "Selling price cannot be less than cost price"})

        return data

    def validate_cost(self, value):
        if value is not None and value < 0:
            raise serializers.ValidationError("cost cannot be negative")
        return value

    def create(self, validated_data):
        # Extract nested data
        images_data = validated_data.pop('images', [])
        variations_data = validated_data.pop('variation_types', [])
        variants_data = validated_data.pop('variants', [])
        # store initial_stock in a variable
        initial_stock = validated_data.pop('initial_stock', 0)
        # Extract other inventory data
        inventory_data = {
            'low_stock_threshold': validated_data.pop('low_stock_threshold', None),
            'reorder_point': validated_data.pop('reorder_point', None),
            'reorder_quantity': validated_data.pop('reorder_quantity', None)
        }

        # Create the product in a transaction
        from django.db import transaction
        with transaction.atomic():
            # Create the product
            product = Product.objects.create(**validated_data)
