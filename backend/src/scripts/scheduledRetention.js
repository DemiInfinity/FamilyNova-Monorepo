/**
 * Scheduled data retention cleanup script
 * Run this via cron job or scheduled task
 * 
 * Example cron: 0 2 * * * (runs daily at 2 AM)
 */

const { cleanupExpiredData, getRetentionStats } = require('../utils/dataRetention');

async function runRetentionCleanup() {
  console.log('[Data Retention] Starting scheduled cleanup...');
  
  try {
    const stats = await getRetentionStats();
    console.log('[Data Retention] Pre-cleanup stats:', stats);
    
    const result = await cleanupExpiredData();
    
    if (result.success) {
      console.log('[Data Retention] Cleanup completed successfully');
      console.log('[Data Retention] Timestamp:', result.timestamp);
    } else {
      console.error('[Data Retention] Cleanup completed with errors:', result.errors);
    }
    
    const postStats = await getRetentionStats();
    console.log('[Data Retention] Post-cleanup stats:', postStats);
    
    return result;
  } catch (error) {
    console.error('[Data Retention] Cleanup failed:', error);
    throw error;
  }
}

// If run directly (not imported)
if (require.main === module) {
  runRetentionCleanup()
    .then(() => {
      console.log('[Data Retention] Script completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('[Data Retention] Script failed:', error);
      process.exit(1);
    });
}

module.exports = { runRetentionCleanup };

