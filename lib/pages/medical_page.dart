import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';
import 'package:shared_accommodation_management_app/views/medical_page_views/add_medical_condition_view.dart';
import 'package:shared_accommodation_management_app/views/medical_page_views/group_members_card_list_view.dart';

import '../features/appbar_display.dart';
import '../view_models/group_view_model.dart';
import 'chores_page.dart';
import 'finance_page.dart';
import 'home_page.dart';

class MedicalPage extends StatefulWidget {

  @override
  State<MedicalPage> createState() {
    return _MedicalPageState();
  }
}

class _MedicalPageState extends State<MedicalPage> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    Provider.of<GroupViewModel>(context, listen: false).returnGroupMembersAsList(user!.uid);
    Provider.of<GroupViewModel>(context, listen: false).memberIds;
    Provider.of<GroupViewModel>(context, listen: false).members;
  }

  int index = 4;
  List<Widget> pages = [HomePage(),ChoresPage(),FinancePage(),ShoppingPage(),MedicalPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(flex: 2, child: Container(color: Colors.red)),
              Expanded(flex: 2, child: Container(color: Colors.green)),
              Expanded(flex: 6, child: GroupMembersCardListView())
            ],
          )),
      floatingActionButton: AddMedicalConditionView(),
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
            ));
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