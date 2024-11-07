import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';

import '../features/appbar_display.dart';
import 'chores_page.dart';
import 'home_page.dart';
import 'medical_page.dart';

class FinancePage extends StatefulWidget {
  // late final Widget body;

  @override
  State<FinancePage> createState() {
    return _FinancePageState();
  }
}

class _FinancePageState extends State<FinancePage> {
  int index = 2;
  List<Widget> pages = [HomePage(),ChoresPage(),FinancePage(),ShoppingPage(),MedicalPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDisplay(),
      body: Center(child: Text('Finance')),
      bottomNavigationBar: setBottomNavigationBar(),
    );
  }

  BottomNavigationBar setBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (newIndex) {
        setState(() {
          index = newIndex;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => pages[index],
            )
        );
      },
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.accessible_forward_sharp), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.ac_unit_rounded), label: "Chores"),
        BottomNavigationBarItem(icon: Icon(Icons.abc), label: "Finance"),
        BottomNavigationBarItem(icon: Icon(Icons.access_alarms_sharp), label: "Shopping"),
        BottomNavigationBarItem(icon: Icon(Icons.reddit_rounded), label: "Medical")
      ],
    );
  }
}