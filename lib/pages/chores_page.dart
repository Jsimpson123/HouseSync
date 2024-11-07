import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/features/appbar_display.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';

import 'finance_page.dart';
import 'home_page.dart';
import 'medical_page.dart';

class ChoresPage extends StatefulWidget {
  // late final Widget body;

  @override
  State<ChoresPage> createState() {
    return _ChoresPageState();
  }
}

class _ChoresPageState extends State<ChoresPage> {
  int index = 1;
  List<Widget> pages = [HomePage(),ChoresPage(),FinancePage(),ShoppingPage(),MedicalPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDisplay(),
      body: Center(child: Text('Chores')),
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
            ));
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