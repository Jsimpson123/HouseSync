import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/features/appbar_display.dart';
import 'package:shared_accommodation_management_app/pages/chores_page.dart';
import 'package:shared_accommodation_management_app/pages/finance_page.dart';
import 'package:shared_accommodation_management_app/pages/login_page.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';
import 'package:shared_accommodation_management_app/view_models/home_view_model.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/bottom_sheets/group_details_bottom_sheet_view.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/group_functions_view.dart';

import '../view_models/user_view_model.dart';
import '../views/home_page_views/home_header_view.dart';
import 'medical_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  List<Widget> pages = [
    HomePage(),
    ChoresPage(),
    FinancePage(),
    ShoppingPage(),
    MedicalPage()
  ];

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBarDisplay(),
  //     body: Center(child: Text('Home')),
  //     bottomNavigationBar: setBottomNavigationBar(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    UserViewModel userViewModel = UserViewModel();

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: userViewModel.colour2),

              //User icon
              currentAccountPicture: const Expanded(
                  child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Icon(Icons.account_circle_rounded))),

              //Username
              accountName: FutureBuilder<String?>(
                  future: userViewModel.returnCurrentUsername(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if ("${snapshot.data}" == "null") {
                      return const Text(
                          ""); //Due to a delay in the username loading
                    } else {
                      return Expanded(
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text("${snapshot.data}",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: userViewModel.colour4)),
                        ),
                      );
                    }
                  }),

              //Email
              accountEmail: FutureBuilder<String?>(
                  future: userViewModel.returnCurrentEmail(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if ("${snapshot.data}" == "null") {
                      return const Text(
                          ""); //Due to a delay in the email loading
                    } else {
                      return Expanded(
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text("${snapshot.data}",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: userViewModel.colour4)),
                        ),
                      );
                    }
                  }),
            ),
            ListTile(
              title: Text("Group"),
              onTap: () => userViewModel.displayBottomSheet(
                  GroupDetailsBottomSheetView(), context),
            ),
      ListTile(title: Text("Settings")),

            ListTile(
              title: Text("Logout"),
              onTap: () async => await FirebaseAuth.instance.signOut()
                  .then((value) =>
                  Navigator.of(context)
                      .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()),(route) => false))
            ),
          ],
        ),
      ),
      body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(flex: 2, child: HomeHeaderView()),
              Expanded(flex: 2, child: Container(color: Colors.green)),
              Expanded(flex: 6, child: Container(color: Colors.red))
            ],
          )),
      // floatingActionButton: AddTaskView(),
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
            // when an item is clicked
            setState(() {
              index = newIndex; // update the index
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
