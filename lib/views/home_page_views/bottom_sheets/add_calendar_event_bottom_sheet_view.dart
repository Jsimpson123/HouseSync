import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/event_model.dart';
import 'package:shared_accommodation_management_app/models/task_model.dart';
import 'package:shared_accommodation_management_app/user_auth/firebase_auth_functionality.dart';
import 'package:shared_accommodation_management_app/view_models/home_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';

class AddCalendarEventBottomSheetView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController enteredEventNameController = TextEditingController();
    User? user = FirebaseAuth.instance.currentUser;

    return Consumer<HomeViewModel>(builder: (context, viewModel, child) {
      return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), //Ensures the keyboard doesn't cover the textfields
          child: Container(
              height: 100,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      decoration: const InputDecoration(
                          hintText: "Event Name", border: OutlineInputBorder()),
                      controller: enteredEventNameController,
                      onSubmitted: (value) {
                        if (enteredEventNameController.text.isNotEmpty) {
                          Event newEvent = Event.newEvent(user!.uid, enteredEventNameController.text);
                          viewModel.addCalendarEvent(newEvent, user.uid);
                          enteredEventNameController.clear();
                        }
                        Navigator.of(context).pop(); //Makes bottom event bar disappear
                      }
                  ),
                ],
              )));
    });
  }
}
