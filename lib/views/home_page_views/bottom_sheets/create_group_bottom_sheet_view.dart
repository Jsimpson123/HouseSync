import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/group_model.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../../global/common/AppColours.dart';
import '../../../pages/home_page.dart';

class CreateGroupBottomSheetView extends StatefulWidget {
  @override
  State<CreateGroupBottomSheetView> createState() {
    return _CreateGroupBottomSheetView();
  }
}

class _CreateGroupBottomSheetView extends State<CreateGroupBottomSheetView> {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

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
                    key: Key("groupNameTextField"),
                      decoration: const InputDecoration(
                          hintText: "Group Name", border: OutlineInputBorder()),
                      controller: enteredGroupNameController
                  ),
                  SizedBox(height: 15),

                  ElevatedButton(
                    key: Key("submitGroupNameButton"),
                      child: Text("Submit"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColours.colour3(brightness),
                          foregroundColor: AppColours.colour1(brightness),
                          fixedSize: Size(100, 50)),
                      onPressed: () async {
                        if (enteredGroupNameController.text.isNotEmpty) {
                          Group newGroup = Group.newGroup(
                              enteredGroupNameController.text);
                          User? user = FirebaseAuth.instance.currentUser;
                          bool groupCreated = await viewModel.createGroup(
                              user!.uid, newGroup.name,
                              viewModel.generateRandomGroupJoinCode());
                          enteredGroupNameController.clear();

                          setState(() {
                            if (groupCreated) {
                              //Executes only one time after the layout is completed
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                //Upon creating a group, it brings the user to the Home page
                                navigateToHome(context);
                              });
                            }
                          });
                        }
                        Navigator.of(context)
                            .pop(); //Makes bottom task bar disappear
                      })
                ],
              )));
    });
  }

  void navigateToHome(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage()));
  }
}
