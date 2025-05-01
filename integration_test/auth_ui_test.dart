import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/firebase_options.dart';
import 'package:shared_accommodation_management_app/main.dart';
import 'package:shared_accommodation_management_app/user_auth/firebase_auth_functionality.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/home_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/user_view_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  //Setup
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late FirebaseAuth auth;
  String rand = "";
  String? groupCode = "";

  //Runs for all tests
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    auth = FirebaseAuth.instance;
  });

  //Runs after test
  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  //Allows text that has been found during a test to be converted to a String
  Future<String?> getTextFromFinder(WidgetTester tester, Finder finder) async {
    final textWidget = tester.widget<Text>(finder);
    return textWidget.data;
  }

  testWidgets('User can register', (WidgetTester tester) async {
    //Launches the app
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => FirebaseAuthFunctionality()),
            ChangeNotifierProvider.value(
              value: GroupViewModel(),
            )
          ],
          child: MyApp(),
        ),
      ),
    );

    String random = const Uuid().v4();
    rand = random;

    //Find register button
    final Finder registerButton = find.byKey(const Key('registerButton'));

    //Click the button to navigate to register page
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    //Ensures the text exists
    expect(find.text("Create Account"), findsOneWidget);

    //Finds widgets on the screen
    final Finder registerUsernameField = find.byKey(const Key('registerUsernameField'));
    final Finder registerEmailField = find.byKey(const Key('registerEmailField'));
    final Finder registerPasswordField = find.byKey(const Key('registerPasswordField'));
    final Finder registerNowButton = find.byKey(const Key('registerNowButton'));

    //Creates a new account
    await tester.enterText(registerUsernameField, 'TestUser');
    await tester.enterText(registerEmailField, '$random@test123.com');
    await tester.enterText(registerPasswordField, 'TestPassword123');
    await tester.tap(registerNowButton);
    await tester.pumpAndSettle();

    //Gives Firebase time
    await Future.delayed(const Duration(seconds: 2));

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
            ChangeNotifierProvider(create: (context) => FirebaseAuthFunctionality()),
            ChangeNotifierProvider.value(
              value: GroupViewModel(),
            ),
            ChangeNotifierProvider(create: (context) => HomeViewModel()),
            ChangeNotifierProvider(create: (context) => UserViewModel())
          ],
          child: MyApp(),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    //Verifies the user is on the login page
    expect(find.text("Welcome"), findsOneWidget);

    // Find TextFields and button
    final Finder emailField = find.byKey(const Key('emailField'));
    final Finder passwordField = find.byKey(const Key('passwordField'));
    final Finder loginButton = find.byKey(const Key('loginButton'));

    //Logs in to pre-created account
    await tester.enterText(emailField, '$rand@test123.com');
    await tester.enterText(passwordField, 'TestPassword123');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    //Gives Firebase time
    await Future.delayed(const Duration(seconds: 2));

    //Verifies the user is logged in
    expect(auth.currentUser, isNotNull);
    expect(auth.currentUser!.email, '$rand@test123.com');

    await tester.pumpAndSettle();

    //Verifies the user is on the correct page
    expect(find.text("Create Group"), findsOneWidget);

    //Finds the button and clicks it
    final Finder createGroupButton = find.byKey(const Key('createGroupButton'));
    await tester.tap(createGroupButton);
    await tester.pumpAndSettle();

    //Enters the group name and clicks submit
    final Finder groupNameTextField = find.byKey(const Key('groupNameTextField'));
    final Finder submitGroupNameButton = find.byKey(const Key('submitGroupNameButton'));
    await tester.enterText(groupNameTextField, 'Group UI Test');
    await tester.tap(submitGroupNameButton);
    await tester.pumpAndSettle();

    //Waits for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    //Verifies the user is on the home page
    expect(find.text("Home"), findsAny);

    //Waits for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    //Finds the group code and converts it to a String
    final Finder groupText = find.byKey(const Key('groupCodeText'));
    groupCode = await getTextFromFinder(tester, groupText);

    //Expects to find the groupCode
    expect(groupCode, isNotNull);
    expect(groupCode?.isNotEmpty, true);
  });

  testWidgets('User can create account and join a group', (WidgetTester tester) async {
    //Launches the app
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => FirebaseAuthFunctionality()),
            ChangeNotifierProvider.value(
              value: GroupViewModel(),
            ),
            ChangeNotifierProvider(create: (context) => HomeViewModel()),
            ChangeNotifierProvider(create: (context) => UserViewModel())
          ],
          child: MyApp(),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    //Verifies the user is on the login page
    expect(find.text("Welcome"), findsOneWidget);

    String random = const Uuid().v4();
    rand = random;

    //Find register button
    final Finder registerButton = find.byKey(const Key('registerButton'));

    //Click the button to navigate to register page
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    //Ensures the text exists
    expect(find.text("Create Account"), findsOneWidget);

    //Finds widgets on the screen
    final Finder registerUsernameField = find.byKey(const Key('registerUsernameField'));
    final Finder registerEmailField = find.byKey(const Key('registerEmailField'));
    final Finder registerPasswordField = find.byKey(const Key('registerPasswordField'));
    final Finder registerNowButton = find.byKey(const Key('registerNowButton'));

    //Creates a new account
    await tester.enterText(registerUsernameField, 'TestUser2');
    await tester.enterText(registerEmailField, '$random@test123.com');
    await tester.enterText(registerPasswordField, 'TestPassword123');
    await tester.tap(registerNowButton);
    await tester.pumpAndSettle();

    //Gives Firebase time
    await Future.delayed(const Duration(seconds: 2));

    //Verifies the user is registered
    expect(auth.currentUser, isNotNull);
    expect(auth.currentUser?.email, '$random@test123.com');

    await tester.pumpAndSettle();

    //Verifies the user is on the correct page
    expect(find.text("Join Group"), findsOneWidget);

    //Finds the button and clicks it
    final Finder joinGroupButton = find.byKey(const Key('joinGroupButton'));
    await tester.tap(joinGroupButton);
    await tester.pumpAndSettle();

    //Enters the group code and clicks submit
    final Finder groupCodeTextField = find.byKey(const Key('groupCodeTextField'));
    final Finder submitGroupNameButton = find.byKey(const Key('submitGroupCodeButton'));
    expect(groupCodeTextField, findsOneWidget);
    await tester.enterText(groupCodeTextField, groupCode!);
    await tester.tap(submitGroupNameButton);
    await tester.pumpAndSettle();

    //Waits for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    //Verifies the user is on the home page
    expect(find.text("Home"), findsAny);

    //Finds the group code and converts it to a String
    final Finder groupText = find.byKey(const Key('groupCodeText'));
    groupCode = await getTextFromFinder(tester, groupText);

    //Expects to find the group code
    expect(find.text(groupCode!), findsAny);
  });
}
