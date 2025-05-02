import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
  });

  test('User registers', () async {
    final userCredential = await mockFirebaseAuth.createUserWithEmailAndPassword(
        email: "testuser@testuser.com", password: "123456");

    expect(userCredential.user, isNotNull);
    expect(userCredential.user?.email, "testuser@testuser.com");
  });

  test('User signs in', () async {
    await mockFirebaseAuth.createUserWithEmailAndPassword(
        email: "testuser@testuser.com", password: "123456");

    final userCredential = await mockFirebaseAuth.signInWithEmailAndPassword(
        email: "testuser@testuser.com", password: "123456");

    expect(userCredential.user, isNotNull);
    expect(userCredential.user?.email, "testuser@testuser.com");
  });

  test('User signs out', () async {
    await mockFirebaseAuth.signInWithEmailAndPassword(
        email: "testuser@testuser.com", password: "123456");

    expect(mockFirebaseAuth.currentUser, isNotNull);

    await mockFirebaseAuth.signOut();

    expect(mockFirebaseAuth.currentUser, isNull);
  });
}
