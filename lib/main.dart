import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/firebase_options.dart';
import 'package:shared_accommodation_management_app/pages/chores_page.dart';
import 'package:shared_accommodation_management_app/pages/create_account_page.dart';
import 'package:shared_accommodation_management_app/pages/create_or_join_group_page.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // name: "HouseSync-Firebase",
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shared Accommodation Management Tool",
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: LoginPage(),
    );
  }
}
