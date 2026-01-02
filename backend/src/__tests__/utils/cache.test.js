const { get, set, del, clear, stats } = require('../../utils/cache');

describe('Cache Utilities', () => {
  beforeEach(() => {
    clear();
  });

  describe('get and set', () => {
    test('should store and retrieve values', () => {
      set('test-key', 'test-value');
      expect(get('test-key')).toBe('test-value');
    });

    test('should return null for non-existent keys', () => {
      expect(get('non-existent')).toBeNull();
    });

    test('should expire values after TTL', (done) => {
      set('expiring-key', 'value', 100); // 100ms TTL
      
      setTimeout(() => {
        expect(get('expiring-key')).toBeNull();
        done();
      }, 150);
    });
  });

  describe('del', () => {
    test('should delete values', () => {
      set('delete-key', 'value');
      expect(get('delete-key')).toBe('value');
      
      del('delete-key');
      expect(get('delete-key')).toBeNull();
    });
  });

  describe('clear', () => {
    test('should clear all cache', () => {
      set('key1', 'value1');
      set('key2', 'value2');
      
      clear();
      
      expect(get('key1')).toBeNull();
      expect(get('key2')).toBeNull();
    });
  });

  describe('stats', () => {
    test('should return cache statistics', () => {
      set('key1', 'value1');
      set('key2', 'value2');
      
      const cacheStats = stats();
      
      expect(cacheStats.valid).toBeGreaterThanOrEqual(0);
      expect(cacheStats.size).toBeGreaterThanOrEqual(0);
    });
  });
});

