
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/user_view_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late FirebaseAuth auth;

  String randomChore = "";

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

  testWidgets('User can create a chore', (WidgetTester tester) async {

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'testuser@test.com',
      password: 'TestPassword123',
    );

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
            ),
            ChangeNotifierProvider(
                create: (context) => TaskViewModel()
            )
          ], child: MyApp(),
        ),
      ),
    );

    String random = const Uuid().v4();
    randomChore = 'TestChore$random';

    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 2));

    //Verifies the user is signed in
    expect(auth.currentUser, isNotNull);
    expect(auth.currentUser?.email, 'testuser@test.com');

    //Verifies the user is on the home page
    expect(find.text("Home"), findsAny);

    //Find createEventButton button
    final Finder choresPage = find.byKey(const Key('choresPage'));

    //Click the button to navigate to bring the popup
    await tester.tap(choresPage);
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 2));

    expect(find.text("Chores"), findsAny);

    //Finds widgets on the screen
    final Finder createChoreButton = find.byKey(const Key('createChoreButton'));

    await tester.tap(createChoreButton);
    await tester.pumpAndSettle();

    final Finder choreTextField = find.byKey(const Key('choreTextField'));

    //Enters text and submits
    await tester.enterText(choreTextField, randomChore);

    final Finder submitChoreButton = find.byKey(const Key('submitChoreButton'));

    await tester.tap(submitChoreButton);
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 3));
    await tester.pump();

    //Verifies the event is created
    expect(find.text(randomChore), findsAny);

    //Cleanup
    final taskSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('title', isEqualTo: randomChore)
        .get();

    for (var doc in taskSnapshot.docs) {
      await doc.reference.delete();
    }
  });

  testWidgets('User can create a chore, assign themself to it and complete it', (WidgetTester tester) async {

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'testuser@test.com',
      password: 'TestPassword123',
    );

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
            ),
            ChangeNotifierProvider(
                create: (context) => TaskViewModel()
            )
          ], child: MyApp(),
        ),
      ),
    );

    // String random = Uuid().v4();
    // randomChore = 'TestChore' + random;

    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 2));

    //Verifies the user is signed in
    expect(auth.currentUser, isNotNull);
    expect(auth.currentUser?.email, 'testuser@test.com');

    //Verifies the user is on the home page
    expect(find.text("Home"), findsAny);

    //Find createEventButton button
    final Finder choresPage = find.byKey(const Key('choresPage'));

    //Click the button to navigate to bring the popup
    await tester.tap(choresPage);
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 2));

    expect(find.text("Chores"), findsAny);

    //Finds widgets on the screen
    final Finder createChoreButton = find.byKey(const Key('createChoreButton'));

    await tester.tap(createChoreButton);
    await tester.pumpAndSettle();

    final Finder choreTextField = find.byKey(const Key('choreTextField'));

    //Enters text and submits
    await tester.enterText(choreTextField, randomChore);

    final Finder submitChoreButton = find.byKey(const Key('submitChoreButton'));

    await tester.tap(submitChoreButton);
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    //Verifies the event is created
    expect(find.text(randomChore), findsAny);

    final Finder assignTaskButton = find.byKey(const Key('assignButton0'));

    await tester.tap(assignTaskButton);
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 3));
    await tester.pump();

    final Finder unassignTaskButton = find.byKey(const Key('unassignButton0'));

    expect(unassignTaskButton, findsOneWidget);
    expect(find.text("TUser"), findsAny);

    //Cleanup
    final taskSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('title', isEqualTo: randomChore)
        .get();

    for (var doc in taskSnapshot.docs) {
      await doc.reference.delete();
    }
  });
}