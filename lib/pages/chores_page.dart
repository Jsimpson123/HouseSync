import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';
import 'package:shared_accommodation_management_app/views/chores_page_views/chores_header_view.dart';
import 'package:shared_accommodation_management_app/views/chores_page_views/task_list_view.dart';

import '../view_models/task_view_model.dart';
import '../view_models/user_view_model.dart';
import '../views/chores_page_views/add_task_view.dart';
import '../views/chores_page_views/task_info_view.dart';
import '../views/home_page_views/bottom_sheets/group_details_bottom_sheet_view.dart';
import 'finance_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'medical_page.dart';

class ChoresPage extends StatefulWidget {
  @override
  State<ChoresPage> createState() {
    return _ChoresPageState();
  }
}

class _ChoresPageState extends State<ChoresPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<TaskViewModel>(context, listen: false).loadTasks();
  }

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
              Expanded(flex: 2, child: ChoresHeaderView()),
              Expanded(flex: 2, child: TaskInfoView()),
              Expanded(flex: 6, child: TaskListView())
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
                icon: Icon(Icons.home), label: "Home"),
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
