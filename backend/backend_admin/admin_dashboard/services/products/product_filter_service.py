import json
import logging
from django.db.models import Q, F
from django.core.exceptions import FieldError
from ecommerce.models import Product, Category
from rest_framework.response import Response
from rest_framework import status
from .base_service import BaseService

class ProductFilterService(BaseService):
    """Service for handling product filtering operations"""
    