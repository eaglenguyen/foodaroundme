import 'package:flutter_test/flutter_test.dart';
import 'package:foodaroundme/authentication/util/auth_validators.dart';

void main() {

  // ─── validateEmail ───────────────────────────────────────────────
  group('validateEmail', () {
    test('returns error for empty email', () {
      expect(validateEmail(''), 'Please enter a valid email.');
    });

    test('returns error for email without @', () {
      expect(validateEmail('invalidemail'), 'Please enter a valid email.');
    });

    test('returns error for email with only @', () {
      expect(validateEmail('@'), 'Please enter a valid email.');
    });

    test('returns null for valid email', () {
      expect(validateEmail('test@example.com'), null);
    });

    test('returns null for email with subdomain', () {
      expect(validateEmail('user@mail.co.uk'), null);
    });
  });

  // ─── validatePassword ────────────────────────────────────────────
  group('validatePassword', () {
    test('returns error for empty password', () {
      expect(validatePassword(''), 'Password must be at least 6 characters.');
    });

    test('returns error for password less than 6 characters', () {
      expect(validatePassword('abc'), 'Password must be at least 6 characters.');
    });

    test('returns error for exactly 5 characters', () {
      expect(validatePassword('abcde'), 'Password must be at least 6 characters.');
    });

    test('returns null for exactly 6 characters', () {
      expect(validatePassword('abcdef'), null);
    });

    test('returns null for password longer than 6 characters', () {
      expect(validatePassword('securepassword123'), null);
    });
  });

  // ─── validateUsername ────────────────────────────────────────────
  group('validateUsername', () {
    test('returns error for empty username', () {
      expect(validateUsername(''), 'Username is required.');
    });

    test('returns error for whitespace only', () {
      expect(validateUsername('   '), 'Username is required.');
    });

    test('returns null for valid username', () {
      expect(validateUsername('john_doe'), null);
    });

    test('returns null for username with spaces', () {
      expect(validateUsername('john doe'), null);
    });
  });

  // ─── validateConfirmPassword ─────────────────────────────────────
  group('validateConfirmPassword', () {
    test('returns error when passwords do not match', () {
      expect(
        validateConfirmPassword('password123', 'password456'),
        'Passwords do not match.',
      );
    });

    test('returns null when passwords match', () {
      expect(
        validateConfirmPassword('password123', 'password123'),
        null,
      );
    });

    test('returns error when confirm is empty', () {
      expect(
        validateConfirmPassword('password123', ''),
        'Passwords do not match.',
      );
    });

    test('is case sensitive', () {
      expect(
        validateConfirmPassword('Password123', 'password123'),
        'Passwords do not match.',
      );
    });
  });
}