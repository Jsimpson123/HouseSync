import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/group_model.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../../pages/home_page.dart';

class JoinGroupBottomSheetView extends StatefulWidget {
  @override
  State<JoinGroupBottomSheetView> createState() {
    return _JoinGroupBottomSheetViewState();
  }
}

class _JoinGroupBottomSheetViewState extends State<JoinGroupBottomSheetView> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController enteredGroupCodeController = TextEditingController();
    
    User? user = FirebaseAuth.instance.currentUser;

    return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
      return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), //Ensures the keyboard doesn't cover the textfields
          child: Container(
              height: 160,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: Key("groupCodeTextField"),
                      decoration: const InputDecoration(
                          hintText: "Group Code", border: OutlineInputBorder()),
                      controller: enteredGroupCodeController,
                  ),

                  SizedBox(height: 15),

                  ElevatedButton(
                    key: Key("submitGroupCodeButton"),
                      child: Text("Submit"),
                      style: ElevatedButton.styleFrom(
                          foregroundColor: viewModel.colour1,
                          backgroundColor: viewModel.colour3,
                        fixedSize: Size(100, 50)
                      ),
                      onPressed: () async {
        if (enteredGroupCodeController.text.isNotEmpty) {
          bool groupExists = await viewModel.joinGroupViaCode(
              user!.uid, enteredGroupCodeController.text);
          enteredGroupCodeController.clear();

          setState(() {
            if (groupExists) {
              //Executes only one time after the layout is completed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                //Upon joining a group, it brings the user to the Home page
                navigateToHome(context);
              });
            }
          });
        }
        Navigator.of(context).pop(); //Makes bottom task bar disappear
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