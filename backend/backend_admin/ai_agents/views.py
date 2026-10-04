from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q, Count
from django.utils.decorators import method_decorator
from django.views.decorators.cache import never_cache
from .models import Agent, AgentExecution, AgentRecommendation
from .serializers import AgentSerializer, AgentExecutionSerializer, AgentRecommendationSerializer
from datetime import datetime, timedelta
