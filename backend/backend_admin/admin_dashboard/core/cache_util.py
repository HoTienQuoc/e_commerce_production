import time
from django.core.cache import cache
import hashlib
import json
import logging

logger = logging.getLogger(__name__)

class CacheUtil:
    def __init__(self, model_name):
        self.model_name = model_name
        self.prefix = f"{model_name}_"

    def get_cache_key(self, query_params=None):
        """Generate a stable cache key based on query parameters"""
        if not query_params:
            return f"{self.prefix}all"

        # Extract only relevant parameters for caching
        cache_relevant_params = {}
        if hasattr(query_params, 'dict'):
            params = query_params.dict()
        else:
            params = dict(query_params)

        relevant_keys = ['search', 'category', 'status', 'stock_status', 'min_price', 'max_price', 'sort_by', 'page', 'page_size']

        for key in relevant_keys:
            if key in params and params[key]:
                cache_relevant_params[key] = params[key]

        # skip caching for bypass requests
        if 'bypass_cache' in params and params['bypass_cache'] == 'true':
            cache_relevant_params['_ts'] = time.time()

        # sort the parameters for consistency
        sorted_params = json.dumps(cache_relevant_params, sort_keys=True)

        # Use MD5 to create a fixed-length hash for the key
        param_hash = hashlib.md5(sorted_params.encode()).hexdigest()

        # Create the key
        key = f"{self.prefix}query_{param_hash}"

        # Register this key
        
