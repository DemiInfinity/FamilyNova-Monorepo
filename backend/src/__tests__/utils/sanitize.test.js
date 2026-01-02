const { sanitizeHTML, sanitizeText, sanitizeInput, sanitizeObject } = require('../../utils/sanitize');

describe('Sanitize Utilities', () => {
  describe('sanitizeHTML', () => {
    test('should remove all HTML tags', () => {
      const input = '<script>alert("xss")</script>Hello';
      const result = sanitizeHTML(input);
      expect(result).toBe('Hello');
    });

    test('should handle empty string', () => {
      expect(sanitizeHTML('')).toBe('');
      expect(sanitizeHTML(null)).toBe('');
    });
  });

  describe('sanitizeText', () => {
    test('should escape HTML entities', () => {
      const input = '<script>alert("xss")</script>';
      const result = sanitizeText(input);
      expect(result).toContain('&lt;');
      expect(result).toContain('&gt;');
      expect(result).not.toContain('<script>');
    });

    test('should handle special characters', () => {
      const input = 'Hello "world" & friends';
      const result = sanitizeText(input);
      expect(result).toContain('&quot;');
      expect(result).toContain('&amp;');
    });
  });

  describe('sanitizeInput', () => {
    test('should remove null bytes', () => {
      const input = 'Hello\0World';
      const result = sanitizeInput(input);
      expect(result).not.toContain('\0');
    });

    test('should trim whitespace', () => {
      const input = '  Hello World  ';
      const result = sanitizeInput(input);
      expect(result).toBe('Hello World');
    });

    test('should remove control characters', () => {
      const input = 'Hello\x00\x1FWorld';
      const result = sanitizeInput(input);
      expect(result).toBe('HelloWorld');
    });
  });

  describe('sanitizeObject', () => {
    test('should sanitize all string values in object', () => {
      const input = {
        name: '  John Doe  ',
        email: 'test@example.com',
        bio: '<script>alert("xss")</script>'
      };
      const result = sanitizeObject(input);
      expect(result.name).toBe('John Doe');
      expect(result.email).toBe('test@example.com');
      expect(result.bio).not.toContain('<script>');
    });

    test('should handle nested objects', () => {
      const input = {
        user: {
          name: '  Jane  ',
          profile: {
            bio: '  Test  '
          }
        }
      };
      const result = sanitizeObject(input);
      expect(result.user.name).toBe('Jane');
      expect(result.user.profile.bio).toBe('Test');
    });

    test('should handle arrays', () => {
      const input = {
        tags: ['  tag1  ', '  tag2  ']
      };
      const result = sanitizeObject(input);
      expect(result.tags[0]).toBe('tag1');
      expect(result.tags[1]).toBe('tag2');
    });
  });
});

