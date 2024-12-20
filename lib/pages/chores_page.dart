import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/features/appbar_display.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';
import 'package:shared_accommodation_management_app/views/add_task_view.dart';
import 'package:shared_accommodation_management_app/views/task_list_view.dart';

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
  List<Widget> pages = [
    HomePage(),
    ChoresPage(),
    FinancePage(),
    ShoppingPage(),
    MedicalPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBarDisplay(),
      body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(flex: 1, child: Container(color: Colors.red)),
              Expanded(flex: 1, child: Container(color: Colors.green)),
              Expanded(flex: 7, child: TaskListView())
            ],
          )),
      floatingActionButton: AddTaskView(),
      bottomNavigationBar: setBottomNavigationBar(),
    );
  }

  PopScope setBottomNavigationBar() {
    return PopScope(
        canPop: false,
        //Ensures that the built-in back button doesn't return to the wrong page
        child: BottomNavigationBar(
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
            BottomNavigationBarItem(
                icon: Icon(Icons.account_box_rounded), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.dry_cleaning_sharp), label: "Chores"),
            BottomNavigationBarItem(
                icon: Icon(Icons.monetization_on), label: "Finance"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "Shopping"),
            BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety), label: "Medical")
          ],
        ));
  }
}
