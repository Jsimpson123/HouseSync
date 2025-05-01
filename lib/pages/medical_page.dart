import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';
import 'package:shared_accommodation_management_app/views/medical_page_views/add_medical_condition_view.dart';
import 'package:shared_accommodation_management_app/views/medical_page_views/group_members_card_list_view.dart';
import 'package:shared_accommodation_management_app/views/medical_page_views/medical_header_view.dart';
import 'package:shared_accommodation_management_app/views/medical_page_views/medical_info_view.dart';

import '../global/common/AppColours.dart';
import '../main.dart';
import '../view_models/group_view_model.dart';
import '../view_models/user_view_model.dart';
import '../views/home_page_views/settings_view.dart';
import 'chores_page.dart';
import 'create_or_join_group_page.dart';
import 'finance_page.dart';
import 'home_page.dart';
import 'login_page.dart';

class MedicalPage extends StatefulWidget {
  const MedicalPage({super.key});


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
    Provider.of<GroupViewModel>(context, listen: false).returnAllGroupMembersAsList(user!.uid);
    Provider.of<GroupViewModel>(context, listen: false).memberIds;
    Provider.of<GroupViewModel>(context, listen: false).members;
  }

  int index = 4;
  List<Widget> pages = [const HomePage(),const ChoresPage(),const FinancePage(),const ShoppingPage(),const MedicalPage()];

  @override
  Widget build(BuildContext context) {
    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

    UserViewModel userViewModel = UserViewModel();

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColours.colour2(brightness)),

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
                                  color: AppColours.colour4(brightness))),
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
                                  color: AppColours.colour4(brightness))),
                        ),
                      );
                    }
                  }),
            ),
            ListTile(
              title: const Text("Group"),
              onTap: () => groupDetails(context)
            ),
            ListTile(title: const Text("Settings"),
              onTap: () => SettingsView.settingsPopup(context, SettingsView()),
            ),

            ListTile(
                title: const Text("Logout"),
                onTap: () async {
                  //Logs the user out then returns them to the login page
                  await FirebaseAuth.instance.signOut()
                      .then((value) =>
                      Navigator.of(context)
                          .pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false));

                  //Resets the apps theme to light mode
                  MyApp.notifier.value = ThemeMode.light;
                }),
            const SizedBox(
              height: 30,
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feedback),
                Icon(Icons.bug_report),
              ],),
            Center(
              child: Text(
                "Want to send feedback or report a bug?",
                style: TextStyle(
                    color: AppColours.colour4(brightness),
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Center(
              child: Text(
                "Email: HouseSync@gmail.com",
                style: TextStyle(
                    color: AppColours.colour4(brightness),
                    fontSize: 14),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            Center(
              child: SizedBox(
                width: 190,
                height: 140,
                child: Image.asset('assets/images/housesync_logo.png'),
              ),
            ),
          ],
        ),
      ),
      body: const SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(flex: 2, child: MedicalHeaderView()),
              Expanded(flex: 2, child: MedicalInfoView()),
              Expanded(flex: 6, child: GroupMembersCardListView())
            ],
          )),
      floatingActionButton: const AddMedicalConditionView(),
      bottomNavigationBar: setBottomNavigationBar(),
    );
  }

  PopScope setBottomNavigationBar() {
    return PopScope(
      //Ensures that the built-in back button doesn't return to the wrong page
        canPop: false,

        //Navigation bar that directs the user to the selected page
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

          //Icons in the bottom nav bar
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.dry_cleaning_sharp), label: "Chores"),
        BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "Finance"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Shopping"),
        BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: "Medical")
      ],
    ));
  }

  //Displays the group details
  Future<void> groupDetails(BuildContext context) async {
    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

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
              title: SizedBox(
                width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FutureBuilder<String?>(
                          future: viewModel.returnGroupName(user!.uid),
                          builder:
                              (BuildContext context, AsyncSnapshot<String?> snapshot) {
                            if ("${snapshot.data}" == "null") {
                              return const Text(
                                  ""); //Due to a delay in the data loading
                            } else {
                              return Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text("${snapshot.data}",
                                      style: TextStyle(
                                          fontSize: isMobile ? 24 : 42,
                                          fontWeight: FontWeight.bold,
                                          color: AppColours.colour4(brightness))),
                                ),
                              );
                            }
                          }),
                    ),

                    //Group code
                    Align(
                      alignment: Alignment.centerRight,
                      child: FutureBuilder<String?>(
                          future: viewModel.returnGroupCode(user!.uid),
                          builder: (BuildContext context,
                              AsyncSnapshot<String?> snapshot) {
                            if ("${snapshot.data}" == "null") {
                              return const Text(
                                  ""); //Due to a delay in the group code loading
                            } else {
                              return Expanded(
                                child: Text("Group Code: \n${snapshot.data}",
                                    style: TextStyle(
                                        fontSize: isMobile ? 14 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColours.colour4(brightness))),
                              );
                            }
                          }),
                    ),
                  ],
                ),
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
                                  color: AppColours.colour2(brightness),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(30))),
                              padding: const EdgeInsets.all(20),
                              child: ListView.separated(
                                  padding: const EdgeInsets.all(15),
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(height: 15);
                                  },
                                  scrollDirection: Axis.vertical,
                                  physics: const ScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: viewModel.memberIds.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        key: UniqueKey(),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: AppColours.colour1(brightness),
                                                borderRadius:
                                                BorderRadius.circular(20)),
                                            child: ListTile(
                                              title: Row(
                                                children: [
                                                  const Icon(Icons.account_box),
                                                  Text(viewModel.members[index],
                                                      style: TextStyle(
                                                          color:
                                                          AppColours.colour4(brightness),
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 20)),
                                                ],
                                              ),
                                            )));
                                  }),
                            ),
                          ),

                          const SizedBox(height: 20),

                          //Leave group button
                          ElevatedButton(
                              onPressed: () {
                                viewModel.leaveGroup(user!.uid);

                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => const CreateOrJoinGroupPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: AppColours.colour1(brightness),
                                  backgroundColor: AppColours.colour3(brightness),
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