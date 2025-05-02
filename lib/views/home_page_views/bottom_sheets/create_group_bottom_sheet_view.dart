import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/group_model.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../../main.dart';
import '../../../pages/home_page.dart';

class CreateGroupBottomSheetView extends StatefulWidget {
  const CreateGroupBottomSheetView({super.key});

  @override
  State<CreateGroupBottomSheetView> createState() {
    return _CreateGroupBottomSheetView();
  }
}

class _CreateGroupBottomSheetView extends State<CreateGroupBottomSheetView> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController enteredGroupNameController = TextEditingController();

    return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
      return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), //Ensures the keyboard doesn't cover the textfield
          child: Container(
              height: 160,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      key: const Key("groupNameTextField"),
                      decoration: const InputDecoration(
                          hintText: "Group Name", border: OutlineInputBorder()),
                      controller: enteredGroupNameController),
                  const SizedBox(height: 15),
                  ElevatedButton(
                      key: const Key("submitGroupNameButton"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          foregroundColor: Colors.grey.shade50,
                          fixedSize: const Size(100, 50)),
                      onPressed: () async {
                        if (enteredGroupNameController.text.isNotEmpty) {
                          Group newGroup = Group.newGroup(enteredGroupNameController.text);
                          User? user = FirebaseAuth.instance.currentUser;
                          bool groupCreated = await viewModel.createGroup(
                              user!.uid, newGroup.name, viewModel.generateRandomGroupJoinCode());
                          enteredGroupNameController.clear();

                          setState(() async {
                            if (groupCreated) {
                              //Checks firebase for the users darkMode setting
                              final doc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get();

                              final isDark = doc.data()?['darkMode'] ?? false;
                              MyApp.notifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

                              //Executes only one time after the layout is completed
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                //Upon creating a group, it brings the user to the Home page
                                navigateToHome(context);
                              });
                            }
                          });
                        }
                        Navigator.of(context).pop(); //Makes bottom task bar disappear
                      },
                      child: const Text("Submit"))
                ],
              )));
    });
  }

  void navigateToHome(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
  }
}
