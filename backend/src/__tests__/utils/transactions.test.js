const { atomicUpdate, upsert, checkAndUpdate } = require('../../utils/transactions');

// Mock Supabase
jest.mock('../../config/database', () => ({
  getSupabase: jest.fn(() => ({
    from: jest.fn(() => ({
      update: jest.fn().mockReturnThis(),
      upsert: jest.fn().mockReturnThis(),
      select: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      single: jest.fn()
    }))
  }))
}));

describe('Transaction Utilities', () => {
  describe('atomicUpdate', () => {
    test('should perform atomic update', async () => {
      const { getSupabase } = require('../../config/database');
      const mockSupabase = getSupabase();
      
      mockSupabase.from().update().eq().eq().select().single.mockResolvedValue({
        data: { id: '1', status: 'updated' },
        error: null
      });

      const result = await atomicUpdate(
        'test_table',
        { id: '1', status: 'pending' },
        { status: 'updated' }
      );

      expect(result.status).toBe('updated');
    });
  });

  describe('upsert', () => {
    test('should perform upsert operation', async () => {
      const { getSupabase } = require('../../config/database');
      const mockSupabase = getSupabase();
      
      mockSupabase.from().upsert().select().single.mockResolvedValue({
        data: { id: '1', name: 'test' },
        error: null
      });

      const result = await upsert(
        'test_table',
        { id: '1', name: 'test' },
        'id'
      );

      expect(result.name).toBe('test');
    });
  });

  describe('checkAndUpdate', () => {
    test('should check and update atomically', async () => {
      const { getSupabase } = require('../../config/database');
      const mockSupabase = getSupabase();
      
      // Mock check query
      const mockSelect = jest.fn().mockReturnThis();
      mockSelect.single = jest.fn().mockResolvedValue({
        data: { id: '1', status: 'pending' },
        error: null
      });
      
      // Mock update query
      const mockUpdate = jest.fn().mockReturnThis();
      mockUpdate.eq = jest.fn().mockReturnThis();
      mockUpdate.select = jest.fn().mockReturnThis();
      mockUpdate.select().single = jest.fn().mockResolvedValue({
        data: { id: '1', status: 'updated' },
        error: null
      });
      
      mockSupabase.from.mockImplementation((table) => {
        if (table === 'test_table') {
          return {
            select: mockSelect,
            update: mockUpdate
          };
        }
      });

      const result = await checkAndUpdate(
        'test_table',
        { id: '1', status: 'pending' },
        { status: 'updated' }
      );

      expect(result.status).toBe('updated');
    });
  });
});

