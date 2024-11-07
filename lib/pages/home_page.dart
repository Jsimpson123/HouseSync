import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/features/appbar_display.dart';
import 'package:shared_accommodation_management_app/pages/chores_page.dart';
import 'package:shared_accommodation_management_app/pages/finance_page.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';

import 'medical_page.dart';

class HomePage extends StatefulWidget {
  // Widget body;

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  List<Widget> pages = [HomePage(),ChoresPage(),FinancePage(),ShoppingPage(),MedicalPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDisplay(),
      body: Center(child: Text('Home')),
      bottomNavigationBar: setBottomNavigationBar(),
    );
  }

  BottomNavigationBar setBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: index,
        onTap: (newIndex) { // when an item is clicked
          setState(() {
            index = newIndex; // update the index
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

