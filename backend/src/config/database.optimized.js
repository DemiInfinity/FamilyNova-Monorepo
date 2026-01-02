/**
 * Optimized database configuration with connection pooling
 */

const { createClient } = require('@supabase/supabase-js');

let supabaseClient = null;
let connectionPool = [];

const MAX_POOL_SIZE = 10;
const POOL_TIMEOUT = 30000; // 30 seconds

/**
 * Get or create Supabase client with connection pooling
 */
function getSupabase() {
  if (!supabaseClient) {
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Supabase URL and key must be provided');
    }

    supabaseClient = createClient(supabaseUrl, supabaseKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false
      },
      db: {
        schema: 'public'
      },
      global: {
        headers: {
          'x-client-info': 'familynova-backend'
        }
      }
    });
  }

  return supabaseClient;
}

/**
 * Get connection from pool (for future use with direct PostgreSQL connections)
 */
function getConnectionFromPool() {
  // For now, Supabase handles connection pooling
  // This is a placeholder for future direct PostgreSQL connection pooling
  return getSupabase();
}

/**
 * Release connection back to pool
 */
function releaseConnection(connection) {
  // Supabase handles this automatically
  // Placeholder for future implementation
}

/**
 * Initialize connection pool
 */
async function initializePool() {
  // Supabase client handles connection pooling internally
  // This is a placeholder for future direct PostgreSQL pooling
  console.log('[Database] Connection pool initialized (Supabase managed)');
}

/**
 * Close all connections
 */
async function closePool() {
  // Supabase handles this automatically
  connectionPool = [];
  supabaseClient = null;
  console.log('[Database] Connection pool closed');
}

/**
 * Get pool statistics
 */
function getPoolStats() {
  return {
    poolSize: connectionPool.length,
    maxPoolSize: MAX_POOL_SIZE,
    provider: 'supabase',
    managed: true
  };
}

module.exports = {
  getSupabase,
  getConnectionFromPool,
  releaseConnection,
  initializePool,
  closePool,
  getPoolStats
};

