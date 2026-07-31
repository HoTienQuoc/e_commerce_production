from django.db import models
import uuid
from django.conf import settings
from django.db.models import JSONField
from django.utils.text import slugify
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.validators import MinValueValidator, MaxLengthValidator
from django.utils import timezone

class Category(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    slug = models.SlugField(max_length=120, null=True, blank=True)
    image = models.ImageField(upload_to='categories/', null=True, blank=True)
    parent = models.ForeignKey('self', null=True, blank=True, on_delete=models.SET_NULL, related_name='children')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name_plural = 'Categories'
        index = [
            models.Index(fields=['name']),
            models.Index(fields=['slug'])
        ]
        ordering = ['name']
        constraints = [
            models.UniqueConstraint(
                fields=['name', 'parent'],
                name='unique_name_parent_combination'
            )
        ]

    def save(self, *args, **kwargs):
        if not self.slug:
            self.slug = slugify(self.name)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class Product(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=200)
    description = models.TextField()
    category = models.ForeignKey(Category, on_delete=models.CASCADE)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    rating = models.DecimalField(max_digits=3, decimal_places=1, default=0)
    reviews_count = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    cost = models.DecimalField(max_digits=10, decimal_places=2)

    @property
    def primary_image(self):
        """Return the primary image or the first image if no primary is set"""
        primary = self.images.filter(is_primary=True).first() # pyright: ignore[reportAttributeAccessIssue]

        if not primary:
            primary = self.images.first() # pyright: ignore[reportAttributeAccessIssue]
        return primary

    @property
    def primary_image_url(self):
        """Return the URL of the primary image"""
        img = self.primary_image
        return img.image.url if img and img.image else None

    @property
    def display_price(self):
        return self.discount_price if self.discount_price is not None else self.price# pyright: ignore[reportAttributeAccessIssue]

    class Meta:
        indexes = [
            models.Index('name', 'category'),
            models.Index(fields=['price']),
            models.Index(fields=['rating']),
            models.Index(fields=['rating']),
            models.Index(fields=['is_active']),
        ]

    def __str__(self):
        return self.name
    

class ProductImage(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    product = models.ForeignKey(Product, related_name='images', on_delete=models.CASCADE)
    image = models.ImageField(upload_to='products/', null=True, blank=True, verbose_name='Product Image')
    alt_text = models.CharField(max_length=200)
    order = models.IntegerField(default=0)
    is_primary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['order']
        indexes = [
            models.Index(fields=['product', 'order'])
        ]

class ProductVariation(models.Model):
    """A category of variation like 'Size', 'Color', etc..."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    product = models.ForeignKey(Product, related_name='variation_types', on_delete=models.CASCADE)
    name = models.CharField(max_length=50)
    values = JSONField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True) 

    class Meta:
        unique_together = ('Product', 'name')


class ProductVariant(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    product = models.ForeignKey(Product, related_name='variation_types', on_delete=models.CASCADE)
    attributes = JSONField(null=True, blank=True)
    sku = models.CharField(max_length=100, blank=True, null=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    discount_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    stock = models.IntegerField(default=0)
    image = models.ForeignKey(ProductImage, null=True, blank=True, on_delete=models.SET_NULL, related_name='variants')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            models.Index(fields=['product']),
        ]


    def save(self, *args, **kwargs):
        if not self.sku:
            product_code = self.product.name[:3].upper()
            variant_code = '-'.join(f"{key[:1]}{val[:2]}" for key, val in sorted(self.attributes.items()))
            self.sku = f"{product_code}-{variant_code}-{uuid.uuid4().hex[:6].upper()}"
        super().save(*args, **kwargs)

    @property
    def effective_price(self):
        return self.discount_price if self.discount_price else self.price or self.product.price


class Order(models.Model):
    STATUS_CHOICES = [
        ('completed', 'Completed'),
        ('processing', 'Processing'),
        ('rejected', 'Rejected'),
        ('on_hold', 'On Hold'),
        ('in_transit', 'In Transit'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey('authentication.CustomUser', on_delete=models.CASCADE)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    shipping_address = models.TextField()
    contact = models.CharField(max_length=20)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='processing')
    tracking_number = models.CharField(max_length=60, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    categories = models.ManyToManyField(Category, through='OrderCategory', related_name='orders')

    class Meta:
        indexes = [
            models.Index(fields=['user', 'status']),
            models.Index(fields=['created_at'])
        ]

    def __str__(self):
        return f"Order {self.id} - {self.user.get_full_name()}"


class OrderCategory(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)

    class Meta:
        unique_togeter = ('order', 'category')

class OrderItem(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.ForeignKey(Order, related_name='itmes', on_delete=models.CASCADE)
    quantity = models.IntegerField()
    size = models.CharField(max_length=10)
    variation = models.CharField(max_length=20)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [
            models.Index(fields=['order', 'product'])
        ]

class Review(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(Product, related_name='reviews', on_delete=models.CASCADE)
    rating = models.IntegerField()
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            models.Index(fields=['product', 'rating']),
            models.Index(fields=['user']),
        ]
        unique_together = ['user', 'product']




