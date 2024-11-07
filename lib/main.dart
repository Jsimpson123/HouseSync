import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       drawer: Drawer(),
  //       appBar: AppBar(
  //         title: Center(child: Text('Shared Accommodation\nManagement App')),
  //         titleTextStyle: TextStyle(color: Colors.red, fontSize: 25),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shared Accommodation Management Tool",
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)
      ),
      home: HomePage(),
    );
  }
}
