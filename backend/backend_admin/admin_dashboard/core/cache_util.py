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
        self.register_key(key)
        return key

    def register_key(self, key):
        """Register a key with Redis SET for efficient tracking"""
        # Try Redis-specific SET operation for better performance
        if hasattr(cache, '_cache') and hasattr(cache._cache, 'get_client'): # pyright: ignore[reportAttributeAccessIssue]
            try:
                redis_client = cache._cache.get_client() # pyright: ignore[reportAttributeAccessIssue]
                registry_set_key = f"{self.prefix}key_set"
                redis_client.sadd(registry_set_key, key)
                redis_client.expire(registry_set_key, 86400*7)
                return 
            except Exception:
                pass

        # Fallback to existing list-based registry
        registry_key = f"{self.prefix}key_registry"
        registered_keys = cache.get(registry_key) or []

        if len(registered_keys) > 1000:
            registered_keys = registered_keys[-900]
        if key not in registered_keys:
            registered_keys.append(key)
            cache.set(registry_key, registered_keys, timeout=86400*7)

    def get_item_cache_key(self, item_id):
        """Generate a cache key for a specific item"""
        return f"{self.prefix}detail_{item_id}"

    def get_list_cache_key(self):
        """Get the cache key for the full list"""
        return f"{self.prefix}list"

    def get_from_cache(self, cache_key):
        """Get data from cache using the key"""
        data = cache.get(cache_key)
        hit_or_miss = "hit" if data is not None else "miss"
        logger.debug(f"Cache {hit_or_miss} for key: {cache_key}")
        return data

    def set_in_cache(self, cache_key, data, timeout=300):
        """Store data in cache with the given key"""
        cache.set(cache_key, data, timeout=timeout)



