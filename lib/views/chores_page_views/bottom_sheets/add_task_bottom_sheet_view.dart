import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/task_model.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';

import '../../../global/common/AppColours.dart';

class AddTaskBottomSheetView extends StatelessWidget {
  const AddTaskBottomSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;
    final TextEditingController enteredTaskNameController = TextEditingController();

    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
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
                    key: const Key("choreTextField"),
                    decoration: const InputDecoration(
                        hintText: "Task Name", border: OutlineInputBorder()),
                    controller: enteredTaskNameController,
                    onSubmitted: (value) {
                    }
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                  key: const Key("submitChoreButton"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours.colour3(brightness),
                    foregroundColor: AppColours.colour1(brightness),
                    fixedSize: const Size(100, 50)),
                  onPressed: () {
                    if (enteredTaskNameController.text.isNotEmpty) {
                      Task newTask = Task.newTask(enteredTaskNameController.text);
                      viewModel.addTask(newTask);
                      enteredTaskNameController.clear();
                    }
                    Navigator.of(context).pop(); //Makes bottom task bar disappear
                  },
                  child: const Text("Submit")
                  )
                ],
              )));
    });
  }
}
