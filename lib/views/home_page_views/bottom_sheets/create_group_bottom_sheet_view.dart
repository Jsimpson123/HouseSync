import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/group_model.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../../pages/home_page.dart';

class CreateGroupBottomSheetView extends StatelessWidget {
  const CreateGroupBottomSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController enteredGroupNameController =
        TextEditingController();

    return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
      return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), //Ensures the keyboard doesn't cover the textfield
          child: Container(
              height: 100,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      decoration: const InputDecoration(
                          hintText: "Group Name", border: OutlineInputBorder()),
                      controller: enteredGroupNameController,
                      onSubmitted: (value) {
                        if (enteredGroupNameController.text.isNotEmpty) {
                          Group newGroup =
                              Group.newGroup(enteredGroupNameController.text);
                          User? user = FirebaseAuth.instance.currentUser;
                          viewModel.createGroup(user!.uid, newGroup.name,
                              viewModel.generateRandomGroupJoinCode());
                          enteredGroupNameController.clear();
                        }
                        Navigator.of(context)
                            .pop(); //Makes bottom task bar disappear

                        //Upon creating a group, it brings the user to the Home page
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      }),
                ],
              )));
    });
  }
}
