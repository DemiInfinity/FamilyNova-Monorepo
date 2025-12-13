const { getSupabase } = require('../config/database');

/**
 * Ensures the user-profiles storage bucket exists
 * Creates it if it doesn't exist
 */
async function ensureStorageBucket() {
  try {
    const supabase = await getSupabase();
    const bucketName = 'user-profiles';

    // Check if bucket exists
    const { data: buckets, error: listError } = await supabase.storage.listBuckets();
    
    if (listError) {
      console.error('Error listing buckets:', listError);
      return { success: false, error: listError };
    }

    const bucketExists = buckets?.some(bucket => bucket.name === bucketName);

    if (!bucketExists) {
      // Create the bucket
      const { data, error: createError } = await supabase.storage.createBucket(bucketName, {
        public: true,
        fileSizeLimit: 5242880, // 5MB in bytes
        allowedMimeTypes: ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
      });

      if (createError) {
        console.error('Error creating bucket:', createError);
        return { success: false, error: createError };
      }

      console.log(`✅ Created storage bucket: ${bucketName}`);
      return { success: true, created: true, data };
    }

    console.log(`✅ Storage bucket exists: ${bucketName}`);
    return { success: true, created: false };
  } catch (error) {
    console.error('Error ensuring storage bucket:', error);
    return { success: false, error };
  }
}

/**
 * Initialize storage bucket on server start
 */
async function initializeStorage() {
  const result = await ensureStorageBucket();
  if (!result.success) {
    console.warn('⚠️  Could not ensure storage bucket exists. Please create it manually in Supabase Dashboard.');
    console.warn('   Bucket name: user-profiles');
    console.warn('   Settings: Public, 5MB limit, image/* MIME types');
  }
  return result;
}

module.exports = {
  ensureStorageBucket,
  initializeStorage
};

