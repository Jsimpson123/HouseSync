import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';
import 'package:shared_accommodation_management_app/views/chores_page_views/chores_header_view.dart';
import 'package:shared_accommodation_management_app/views/chores_page_views/task_list_view.dart';

import '../view_models/group_view_model.dart';
import '../view_models/task_view_model.dart';
import '../view_models/user_view_model.dart';
import '../views/chores_page_views/add_task_view.dart';
import '../views/chores_page_views/task_info_view.dart';
import '../views/home_page_views/bottom_sheets/group_details_bottom_sheet_view.dart';
import 'create_or_join_group_page.dart';
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
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Provider.of<TaskViewModel>(context, listen: false).loadTasks();
    Provider.of<GroupViewModel>(context, listen: false).returnAllGroupMembersAsList(user!.uid);
    Provider.of<GroupViewModel>(context, listen: false).memberIds;
    Provider.of<GroupViewModel>(context, listen: false).members;
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
              onTap: () => groupDetails(context),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  Future<void> groupDetails(BuildContext context) async {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
            return AlertDialog(
              scrollable: true,
              //Group name
              title: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: FutureBuilder<String?>(
                      future: viewModel.returnGroupName(user!.uid),
                      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                        if ("${snapshot.data}" == "null") {
                          return const SizedBox.shrink();
                        } else {
                              return Text(
                                "${snapshot.data}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isMobile ? 24 : 42,
                                  fontWeight: FontWeight.bold,
                                  color: viewModel.colour4,
                                ),
                              );
                        }
                      },
                    ),
                  ),


                  Flexible(
                    child: FutureBuilder<String?>(
                      future: viewModel.returnGroupCode(user!.uid),
                      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                        if ("${snapshot.data}" == "null") {
                          return const SizedBox.shrink();
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Group Code:",
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: viewModel.colour4,
                                ),
                              ),
                              Text(
                                "${snapshot.data}",
                                style: TextStyle(
                                  fontSize: isMobile ? 18 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: viewModel.colour4,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),

                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: viewModel.colour2,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(30))),
                              padding: EdgeInsets.all(20),
                              child: ListView.separated(
                                  padding: EdgeInsets.all(15),
                                  separatorBuilder: (context, index) {
                                    return SizedBox(height: 15);
                                  },
                                  scrollDirection: Axis.vertical,
                                  physics: ScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: viewModel.memberIds.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        key: UniqueKey(),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: viewModel.colour1,
                                                borderRadius:
                                                BorderRadius.circular(20)),
                                            child: ListTile(
                                              title: Row(
                                                children: [
                                                  Icon(Icons.account_box),
                                                  Text(viewModel.members[index],
                                                      style: TextStyle(
                                                          color:
                                                          viewModel.colour4,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 20)),
                                                ],
                                              ),
                                              // onTap: () =>
                                              //     viewSpecificUsersMedicalConditionsPopup(
                                              //         context, viewModel.memberIds[index]),
                                            )));
                                  }),
                            ),
                          ),

                          SizedBox(height: 20),

                          //Leave group button
                          ElevatedButton(
                              onPressed: () {
                                viewModel.leaveGroup(user!.uid);

                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => CreateOrJoinGroupPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: viewModel.colour1,
                                  backgroundColor: viewModel.colour3,
                                  textStyle:
                                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              child: const Text("Leave Group")),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
