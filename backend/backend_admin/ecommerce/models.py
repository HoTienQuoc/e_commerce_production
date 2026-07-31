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
    