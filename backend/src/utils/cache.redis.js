/**
 * Redis cache implementation (production-ready)
 * Falls back to in-memory cache if Redis is not available
 */

let redisClient = null;
const inMemoryCache = require('./cache');

// Try to initialize Redis
try {
  const redis = require('redis');
  
  if (process.env.REDIS_URL) {
    redisClient = redis.createClient({
      url: process.env.REDIS_URL
    });
    
    redisClient.on('error', (err) => {
      console.warn('[Cache] Redis error, falling back to in-memory cache:', err.message);
      redisClient = null;
    });
    
    redisClient.on('connect', () => {
      console.log('[Cache] Redis connected');
    });
    
    redisClient.connect().catch(() => {
      console.warn('[Cache] Redis connection failed, using in-memory cache');
      redisClient = null;
    });
  }
} catch (error) {
  console.warn('[Cache] Redis not available, using in-memory cache');
}

/**
 * Get value from cache (Redis or in-memory)
 */
async function get(key) {
  if (redisClient && redisClient.isReady) {
    try {
      const value = await redisClient.get(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.warn('[Cache] Redis get error, falling back:', error.message);
      return inMemoryCache.get(key);
    }
  }
  return inMemoryCache.get(key);
}

/**
 * Set value in cache (Redis or in-memory)
 */
async function set(key, value, ttl = 300000) { // Default 5 minutes
  if (redisClient && redisClient.isReady) {
    try {
      const ttlSeconds = Math.floor(ttl / 1000);
      await redisClient.setEx(key, ttlSeconds, JSON.stringify(value));
      return;
    } catch (error) {
      console.warn('[Cache] Redis set error, falling back:', error.message);
    }
  }
  inMemoryCache.set(key, value, ttl);
}

/**
 * Delete value from cache
 */
async function del(key) {
  if (redisClient && redisClient.isReady) {
    try {
      await redisClient.del(key);
      return;
    } catch (error) {
      console.warn('[Cache] Redis del error, falling back:', error.message);
    }
  }
  inMemoryCache.del(key);
}

/**
 * Clear all cache
 */
async function clear() {
  if (redisClient && redisClient.isReady) {
    try {
      await redisClient.flushDb();
      return;
    } catch (error) {
      console.warn('[Cache] Redis clear error, falling back:', error.message);
    }
  }
  inMemoryCache.clear();
}

/**
 * Get cache statistics
 */
async function stats() {
  if (redisClient && redisClient.isReady) {
    try {
      const info = await redisClient.info('stats');
      const keys = await redisClient.dbSize();
      return {
        type: 'redis',
        keys,
        info: info.split('\n').slice(0, 5).join('\n')
      };
    } catch (error) {
      console.warn('[Cache] Redis stats error, falling back:', error.message);
    }
  }
  const memStats = inMemoryCache.stats();
  return {
    type: 'memory',
    ...memStats
  };
}

/**
 * Check if Redis is available
 */
function isRedisAvailable() {
  return redisClient && redisClient.isReady;
}

module.exports = {
  get,
  set,
  del,
  clear,
  stats,
  isRedisAvailable
};

