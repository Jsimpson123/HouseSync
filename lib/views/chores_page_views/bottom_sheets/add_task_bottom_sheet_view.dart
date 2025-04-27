import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/task_model.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';

class AddTaskBottomSheetView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController enteredTaskNameController = TextEditingController();

    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
      return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), //Ensures the keyboard doesn't cover the textfields
          child: Container(
              height: 150,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: Key("choreTextField"),
                    decoration: const InputDecoration(
                        hintText: "Task Name", border: OutlineInputBorder()),
                    controller: enteredTaskNameController,
                    onSubmitted: (value) {
                      // if (enteredTaskNameController.text.isNotEmpty) {
                      //   Task newTask = Task.newTask(enteredTaskNameController.text);
                      //   viewModel.addTask(newTask);
                      //   enteredTaskNameController.clear();
                      // }
                      // Navigator.of(context).pop(); //Makes bottom task bar disappear
                    }
                  ),

                  SizedBox(height: 15),

                  ElevatedButton(
                  key: Key("submitChoreButton"),
                  child: Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: viewModel.colour3,
                    foregroundColor: viewModel.colour1,
                    fixedSize: Size(100, 50)),
                  onPressed: () {
                    if (enteredTaskNameController.text.isNotEmpty) {
                      Task newTask = Task.newTask(enteredTaskNameController.text);
                      viewModel.addTask(newTask);
                      enteredTaskNameController.clear();
                    }
                    Navigator.of(context).pop(); //Makes bottom task bar disappear
                  }
                  )
                ],
              )));
    });
  }
}
