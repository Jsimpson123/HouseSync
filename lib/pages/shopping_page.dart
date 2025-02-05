import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/views/shopping_page_views/add_shopping_list_view.dart';

import '../features/appbar_display.dart';
import 'chores_page.dart';
import 'finance_page.dart';
import 'home_page.dart';
import 'medical_page.dart';

class ShoppingPage extends StatefulWidget {
  // late final Widget body;

  @override
  State<ShoppingPage> createState() {
    return _ShoppingPageState();
  }
}

class _ShoppingPageState extends State<ShoppingPage> {
  int index = 3;
  List<Widget> pages = [HomePage(),ChoresPage(),FinancePage(),ShoppingPage(),MedicalPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(flex: 2, child: Container(color: Colors.red)),
              Expanded(flex: 2, child: Container(color: Colors.green,)),
              Expanded(flex: 6, child: Container(color: Colors.green,)),
              // Expanded(flex: 6, child: ExpenseCardListView())
            ],
          )),
      floatingActionButton: AddShoppingListView(),
      bottomNavigationBar: setBottomNavigationBar(),
    );
  }

  PopScope setBottomNavigationBar() {
    return PopScope(
        canPop: false, //Ensures that the built-in back button doesn't return to the wrong page
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
            )
        );
      },
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.account_box_rounded), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.dry_cleaning_sharp), label: "Chores"),
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "Finance"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Shopping"),
        BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: "Medical")
      ],
    ));
  }
}