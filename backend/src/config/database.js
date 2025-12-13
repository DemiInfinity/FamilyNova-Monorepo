const { createClient } = require('@supabase/supabase-js');

let supabase = null;

const connectDB = async () => {
  try {
    const supabaseUrl = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;
    
    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Missing Supabase credentials. Please set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in .env');
    }
    
    // Use service role key for admin operations (creating users, etc.)
    // For regular auth operations, we'll use the anon key
    supabase = createClient(supabaseUrl, supabaseKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false
      }
    });
    
    // Test connection (only in non-serverless environments)
    // In Vercel/serverless, we'll skip the connection test to avoid cold start delays
    if (process.env.VERCEL !== '1' && !process.env.VERCEL_ENV) {
      const { data, error } = await supabase.from('users').select('count').limit(1);
      
      if (error && error.code !== 'PGRST116') { // PGRST116 = table doesn't exist (expected on first run)
        console.error('Supabase connection test error:', error);
        throw error;
      }
      
      console.log(`✅ Supabase Connected: ${supabaseUrl}`);
    } else {
      console.log(`✅ Supabase Client Initialized (serverless mode)`);
    }
    
    return supabase;
  } catch (error) {
    console.error(`❌ Supabase connection error: ${error.message}`);
    // Don't exit process in serverless environments
    if (process.env.VERCEL !== '1' && !process.env.VERCEL_ENV) {
      process.exit(1);
    }
    throw error;
  }
};

const getSupabase = () => {
  // In serverless, lazy-initialize if not already connected
  if (!supabase) {
    const supabaseUrl = process.env.SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;
    
    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Missing Supabase credentials. Please set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
    }
    
    // Create client synchronously (Supabase client creation is synchronous)
    supabase = createClient(supabaseUrl, supabaseKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false
      }
    });
    
    console.log('✅ Supabase Client Initialized (lazy)');
  }
  return supabase;
};

module.exports = { connectDB, getSupabase };
