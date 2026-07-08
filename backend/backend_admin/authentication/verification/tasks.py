import logging
from celery import shared_task
from django.contrib.auth import get_user_model
from emails import EmailService