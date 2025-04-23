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
import 'package:shared_accommodation_management_app/view_models/home_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/user_view_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late FirebaseAuth auth;

  String rand = "";

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      auth = FirebaseAuth.instance;
    });

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

    testWidgets('User can register', (WidgetTester tester) async {
      //Launches the app
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(
              create: (context) => FirebaseAuthFunctionality()
            ),
              ChangeNotifierProvider.value(
              value: GroupViewModel(),
            )
              ], child: MyApp(),
            ),
          ),
        );

      String random = Uuid().v4();
      rand = random;

      //Find register button
      final Finder registerButton = find.byKey(Key('registerButton'));

      //Click the button to navigate to register page
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      //Ensures the text exists
      expect(find.text("Create Account"), findsOneWidget);

      //Finds widgets on the screen
      final Finder registerUsernameField = find.byKey(Key('registerUsernameField'));
      final Finder registerEmailField = find.byKey(Key('registerEmailField'));
      final Finder registerPasswordField = find.byKey(Key('registerPasswordField'));
      final Finder registerNowButton = find.byKey(Key('registerNowButton'));

      //Creates a new account
      await tester.enterText(registerUsernameField, 'TestUser');
      await tester.enterText(registerEmailField, '$random@test123.com');
      await tester.enterText(registerPasswordField, 'TestPassword123');
      await tester.tap(registerNowButton);
      await tester.pumpAndSettle();

      //Gives Firebase time
      await Future.delayed(Duration(seconds: 2));

      //Verifies the user is registered
      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser?.email, '$random@test123.com');
    });

  testWidgets('User can sign in and create a group', (WidgetTester tester) async {
    //Launches the app
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (context) => FirebaseAuthFunctionality()
            ),
            ChangeNotifierProvider.value(
              value: GroupViewModel(),
            ),
            ChangeNotifierProvider(
                create: (context) => HomeViewModel()
            ),
            ChangeNotifierProvider(
                create: (context) => UserViewModel()
            )
          ], child: MyApp(),
        ),
      ),
    );

    await Future.delayed(Duration(seconds: 2));

    //Verifies the user is on the login page
    expect(find.text("Welcome"), findsOneWidget);

    // Find TextFields and button
    final Finder emailField = find.byKey(Key('emailField'));
    final Finder passwordField = find.byKey(Key('passwordField'));
    final Finder loginButton = find.byKey(Key('loginButton'));

    //Logs in to pre-created account
    await tester.enterText(emailField, '$rand@test123.com');
    await tester.enterText(passwordField, 'TestPassword123');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    //Gives Firebase time
    await Future.delayed(Duration(seconds: 2));

    //Verifies the user is logged in
    expect(auth.currentUser, isNotNull);
    expect(auth.currentUser!.email, '$rand@test123.com');

    await tester.pumpAndSettle();

    //Verifies the user is on the correct page
    expect(find.text("Create Group"), findsOneWidget);

    //Finds the button and clicks it
    final Finder createGroupButton = find.byKey(Key('createGroupButton'));
    await tester.tap(createGroupButton);
    await tester.pumpAndSettle();

    //Enters the group name and clicks submit
    final Finder groupNameTextField = find.byKey(Key('groupNameTextField'));
    final Finder submitGroupNameButton = find.byKey(Key('submitGroupNameButton'));
    await tester.enterText(groupNameTextField, 'Group UI Test');
    await tester.tap(submitGroupNameButton);
    await tester.pumpAndSettle();

    await Future.delayed(Duration(seconds: 2));
    await tester.pumpAndSettle();

    //Verifies the user is on the home page
    expect(find.text("Home"), findsAny);
  });
}