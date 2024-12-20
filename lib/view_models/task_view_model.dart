import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/task_model.dart';

class TaskViewModel extends ChangeNotifier {
  List<Task> tasks = <Task>[];

  Color colour1 = Colors.grey.shade50;
  Color colour2 = Colors.grey.shade200;
  Color colour3 = Colors.grey.shade800;
  Color colour4 = Colors.grey.shade900;

  int get numTasks => tasks.length;

  void addTask(Task newTask) {
    tasks.add(newTask);
    notifyListeners();
  }

  bool getTaskValue(int taskIndex) {
    return tasks[taskIndex].complete;
  }

  void setTaskValue(int taskIndex, bool taskValue) {
    tasks[taskIndex].complete = taskValue;
    notifyListeners();
  }

  String getTaskTitle(int taskIndex) {
    return tasks[taskIndex].title;
  }

  void displayBottomSheet(Widget bottomSheetView, BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: ((context) {
          return bottomSheetView;
    }));
  }
}