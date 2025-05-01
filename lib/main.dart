import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/firebase_options.dart';
import 'package:shared_accommodation_management_app/pages/home_page.dart';
import 'package:shared_accommodation_management_app/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_accommodation_management_app/view_models/finance_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/home_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/medical_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/user_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // name: "HouseSync-Firebase",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  var isDarkMode = prefs.getBool('isDarkMode') ?? false;

  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    isDarkMode = userDoc.data()?['darkMode'] ?? false;
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => TaskViewModel()
    ),
    ChangeNotifierProvider(
        create: (context) => UserViewModel()
    ),
    ChangeNotifierProvider(
        create: (context) => GroupViewModel()
    ),
    ChangeNotifierProvider(
        create: (context) => FinanceViewModel()
    ),
    ChangeNotifierProvider(
        create: (context) => ShoppingViewModel()
    ),
    ChangeNotifierProvider(
        create: (context) => MedicalViewModel()
    ),
    ChangeNotifierProvider(
        create: (context) => HomeViewModel()
    ),
  ],
      child: MyApp(isDarkMode: isDarkMode)));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, this.isDarkMode = false}) {
    notifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  User? user = FirebaseAuth.instance.currentUser;

  static final ValueNotifier<ThemeMode> notifier = ValueNotifier(ThemeMode.light);

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: notifier,
        builder: (_, mode, __) {
          return MaterialApp(
            title: "Shared Accommodation Management Tool",
            theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.dark(
                primary: Colors.teal,
                onSurface: Colors.white,
                onPrimary: Colors.black,
                surface: Colors.grey.shade900,
              ),
            ),
            themeMode: mode,
            home: user == null ? const LoginPage() : const HomePage(),
            debugShowCheckedModeBanner: false,
          );
        }
    );
  }
}
