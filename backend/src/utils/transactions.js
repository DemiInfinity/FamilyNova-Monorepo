const { getSupabase } = require('../config/database');
const { createError } = require('../middleware/errorHandler');

/**
 * Execute multiple database operations in a transaction-like manner
 * Note: Supabase doesn't support true transactions via JS client,
 * but we can use RPC functions or ensure atomicity through careful ordering
 */
async function executeTransaction(operations) {
  const supabase = getSupabase();
  const results = [];
  const errors = [];

  // Execute operations sequentially to maintain order
  for (let i = 0; i < operations.length; i++) {
    const operation = operations[i];
    try {
      let result;
      
      switch (operation.type) {
        case 'insert':
          result = await supabase
            .from(operation.table)
            .insert(operation.data)
            .select();
          break;
          
        case 'update':
          result = await supabase
            .from(operation.table)
            .update(operation.data)
            .eq(operation.column, operation.value)
            .select();
          break;
          
        case 'delete':
          result = await supabase
            .from(operation.table)
            .delete()
            .eq(operation.column, operation.value);
          break;
          
        case 'custom':
          result = await operation.execute(supabase);
          break;
          
        default:
          throw new Error(`Unknown operation type: ${operation.type}`);
      }
      
      if (result.error) {
        throw result.error;
      }
      
      results.push(result.data);
    } catch (error) {
      errors.push({
        operation: i,
        error: error.message || error
      });
      
      // Rollback: attempt to undo previous operations
      // Note: This is best-effort, not a true rollback
      if (operation.rollback) {
        try {
          await operation.rollback(supabase);
        } catch (rollbackError) {
          console.error('[Transaction] Rollback failed:', rollbackError);
        }
      }
      
      // Stop execution on error
      throw createError(
        `Transaction failed at operation ${i + 1}`,
        500,
        'TRANSACTION_FAILED',
        { errors, completed: results }
      );
    }
  }
  
  return results;
}

/**
 * Atomic update operation (check and update in one query)
 */
async function atomicUpdate(table, conditions, updates) {
  const supabase = getSupabase();
  
  let query = supabase.from(table).update(updates);
  
  // Apply conditions
  Object.entries(conditions).forEach(([key, value]) => {
    query = query.eq(key, value);
  });
  
  const { data, error } = await query.select().single();
  
  if (error) {
    throw createError('Atomic update failed', 500, 'ATOMIC_UPDATE_FAILED', error);
  }
  
  return data;
}

/**
 * Atomic insert or update (upsert)
 */
async function upsert(table, data, conflictColumn) {
  const supabase = getSupabase();
  
  const { data: result, error } = await supabase
    .from(table)
    .upsert(data, {
      onConflict: conflictColumn
    })
    .select()
    .single();
  
  if (error) {
    throw createError('Upsert failed', 500, 'UPSERT_FAILED', error);
  }
  
  return result;
}

/**
 * Check and update atomically (for race condition prevention)
 */
async function checkAndUpdate(table, checkConditions, updates) {
  const supabase = getSupabase();
  
  // First check
  let checkQuery = supabase.from(table).select('*');
  Object.entries(checkConditions).forEach(([key, value]) => {
    checkQuery = checkQuery.eq(key, value);
  });
  
  const { data: existing, error: checkError } = await checkQuery.single();
  
  if (checkError && checkError.code !== 'PGRST116') {
    throw createError('Check failed', 500, 'CHECK_FAILED', checkError);
  }
  
  if (!existing) {
    throw createError('Record not found', 404, 'NOT_FOUND');
  }
  
  // Then update
  let updateQuery = supabase.from(table).update(updates);
  Object.entries(checkConditions).forEach(([key, value]) => {
    updateQuery = updateQuery.eq(key, value);
  });
  
  const { data: updated, error: updateError } = await updateQuery.select().single();
  
  if (updateError) {
    throw createError('Update failed', 500, 'UPDATE_FAILED', updateError);
  }
  
  return updated;
}

module.exports = {
  executeTransaction,
  atomicUpdate,
  upsert,
  checkAndUpdate
};

