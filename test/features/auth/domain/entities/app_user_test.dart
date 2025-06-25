import 'package:flutter_test/flutter_test.dart';
import 'package:filmflow/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser', () {
    test('creates instance with required properties', () {
      final createdAt = DateTime.now();
      final lastSignInAt = DateTime.now();

      final user = AppUser(
        uid: 'uid123',
        email: 'user@test.com',
        createdAt: createdAt,
        lastSignInAt: lastSignInAt,
        isEmailVerified: false,
      );

      expect(user.uid, 'uid123');
      expect(user.email, 'user@test.com');
      expect(user.displayName, isNull);
      expect(user.photoURL, isNull);
      expect(user.createdAt, createdAt);
      expect(user.lastSignInAt, lastSignInAt);
      expect(user.isEmailVerified, false);
    });

    test('copyWith returns new instance with updated values', () {
      final originalUser = AppUser(
        uid: 'uid1',
        email: 'old@email.com',
        createdAt: DateTime(2023, 1, 1),
        lastSignInAt: DateTime(2023, 1, 1),
        isEmailVerified: false,
      );

      final updatedUser = originalUser.copyWith(
        email: 'new@email.com',
        displayName: 'New Name',
        isEmailVerified: true,
      );

      expect(updatedUser.uid, 'uid1');
      expect(updatedUser.email, 'new@email.com');
      expect(updatedUser.displayName, 'New Name');
      expect(updatedUser.isEmailVerified, true);
      expect(updatedUser.createdAt, originalUser.createdAt);
    });

    test('equality is based on uid only', () {
      final user1 = AppUser(
        uid: 'same-uid',
        email: 'email1@test.com',
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
        isEmailVerified: true,
      );

      final user2 = AppUser(
        uid: 'same-uid',
        email: 'email2@test.com',
        displayName: 'Different Name',
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
        isEmailVerified: false,
      );

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('different uids are not equal', () {
      final user1 = AppUser(
        uid: 'uid1',
        email: 'same@email.com',
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
        isEmailVerified: true,
      );

      final user2 = AppUser(
        uid: 'uid2',
        email: 'same@email.com',
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
        isEmailVerified: true,
      );

      expect(user1, isNot(equals(user2)));
      expect(user1.hashCode, isNot(equals(user2.hashCode)));
    });

    test('toString includes uid, email, and displayName', () {
      final user = AppUser(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
        isEmailVerified: true,
      );

      final toString = user.toString();
      expect(toString, contains('test-uid'));
      expect(toString, contains('test@example.com'));
      expect(toString, contains('Test User'));
    });
  });
}
