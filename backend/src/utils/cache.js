// Simple in-memory cache (for production, use Redis)
const cache = new Map();
const DEFAULT_TTL = 5 * 60 * 1000; // 5 minutes

/**
 * Get value from cache
 */
function get(key) {
  const item = cache.get(key);
  if (!item) return null;
  
  if (Date.now() > item.expiresAt) {
    cache.delete(key);
    return null;
  }
  
  return item.value;
}

/**
 * Set value in cache
 */
function set(key, value, ttl = DEFAULT_TTL) {
  cache.set(key, {
    value,
    expiresAt: Date.now() + ttl
  });
}

/**
 * Delete value from cache
 */
function del(key) {
  cache.delete(key);
}

/**
 * Clear all cache
 */
function clear() {
  cache.clear();
}

/**
 * Get cache statistics
 */
function stats() {
  const now = Date.now();
  let valid = 0;
  let expired = 0;
  
  for (const [key, item] of cache.entries()) {
    if (Date.now() > item.expiresAt) {
      expired++;
      cache.delete(key);
    } else {
      valid++;
    }
  }
  
  return {
    total: valid + expired,
    valid,
    expired,
    size: cache.size
  };
}

// Cleanup expired entries every minute
setInterval(() => {
  const now = Date.now();
  for (const [key, item] of cache.entries()) {
    if (now > item.expiresAt) {
      cache.delete(key);
    }
  }
}, 60 * 1000);

module.exports = {
  get,
  set,
  del,
  clear,
  stats
};

