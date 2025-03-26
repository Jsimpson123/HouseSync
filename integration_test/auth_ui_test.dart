import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/firebase_options.dart';
import 'package:shared_accommodation_management_app/main.dart';
import 'package:shared_accommodation_management_app/pages/login_page.dart';
import 'package:shared_accommodation_management_app/user_auth/firebase_auth_functionality.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late FirebaseAuth auth;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      auth = FirebaseAuth.instance;
    });

    testWidgets('User can register and sign in', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
              create: (context) => FirebaseAuthFunctionality()
            ),
              ChangeNotifierProvider(
              create: (context) => GroupViewModel()
            )
              ], child: MyApp(),
            ),
          ),
        );

      // Find TextFields and buttons
      final Finder emailField = find.byKey(Key('emailField'));
      final Finder passwordField = find.byKey(Key('passwordField'));
      final Finder loginButton = find.byKey(Key('loginButton'));
      final Finder registerButton = find.byKey(Key('registerButton'));

      //Click the button to navigate to register page
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text("Create Account"), findsOneWidget);

      final Finder registerUsernameField = find.byKey(Key('registerUsernameField'));
      final Finder registerEmailField = find.byKey(Key('registerEmailField'));
      final Finder registerPasswordField = find.byKey(Key('registerPasswordField'));
      final Finder registerNowButton = find.byKey(Key('registerNowButton'));

      //Creates a new account
      await tester.enterText(registerUsernameField, 'TestUser');
      await tester.enterText(registerEmailField, 'testuser123@test123.com');
      await tester.enterText(registerPasswordField, 'TestPassword123');

      await tester.tap(registerNowButton);
      await tester.pumpAndSettle();

      //Verifies the user is registered
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.email, 'testuser123@test123.com');

      //Somehow make it return to the login page here

      //Signs the user in
      await tester.enterText(emailField, 'testuser@example.com');
      await tester.enterText(passwordField, 'TestPassword123');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      //Verifies the user is Signed in
      // expect(auth.currentUser, isNotNull);
      // expect(auth.currentUser!.email, 'testuser123@test123.com');
    });
}