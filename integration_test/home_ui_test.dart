
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

  testWidgets('User can create an event', (WidgetTester tester) async {

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
            )
          ], child: MyApp(),
        ),
      ),
    );

    String random = const Uuid().v4();
    rand = random;

    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 2));

    //Verifies the user is signed in
    expect(auth.currentUser, isNotNull);
    expect(auth.currentUser?.email, 'testuser@test.com');

    //Verifies the user is on the home page
    expect(find.text("Home"), findsAny);

    //Find createEventButton button
    final Finder createEventButton = find.byKey(const Key('createEventButton'));

    //Click the button to navigate to bring the popup
    await tester.tap(createEventButton);
    await tester.pumpAndSettle();

    //Finds widgets on the screen
    final Finder eventTextField = find.byKey(const Key('eventTextField'));
    final Finder submitEventButton = find.byKey(const Key('submitEventButton'));

    //Enters text and submits
    await tester.enterText(eventTextField, 'TestEvent$rand');
    await tester.tap(submitEventButton);
    await tester.pumpAndSettle();

    //Verifies the user is on the time picker
    expect(find.text("Select time"), findsOneWidget);
    final Finder okButton = find.text('OK');
    expect(okButton, findsOneWidget);

    //Clicks OK button
    await tester.tap(okButton);
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 3));
    await tester.pump();

    //Verifies the event is created
    expect(find.text('TestEvent$rand'), findsAny);

    //Cleanup
    final eventSnapshot = await FirebaseFirestore.instance
        .collection('calendarEvents')
        .where('title', isEqualTo: 'TestEvent$rand')
        .get();

    for (var doc in eventSnapshot.docs) {
      await doc.reference.delete();
    }
  });
}