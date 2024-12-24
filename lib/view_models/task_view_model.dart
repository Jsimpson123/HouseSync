import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/task_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Task> _tasks = <Task>[];
  List<Task> get tasks => List.unmodifiable(_tasks);


  Color colour1 = Colors.grey.shade50;
  Color colour2 = Colors.grey.shade200;
  Color colour3 = Colors.grey.shade800;
  Color colour4 = Colors.grey.shade900;

  int get numTasks => _tasks.length;

  // TaskViewModel() {
  //   fetchTasks();
  // }

  Future <void> loadTasks() async {
    final snapshot = await _firestore.collection('tasks').get();
    _tasks.clear();
    for (var doc in snapshot.docs) {
      _tasks.add(Task.fromMap(doc.id, doc.data()));
    }
    notifyListeners();
  }

  Future<void> addTask(Task newTask) async {
    newTask.generateId();

    await _firestore.collection('tasks').doc(newTask.taskId).set({
      'taskId': newTask.taskId,
      'title': newTask.title,
      'isCompleted': newTask.isCompleted
    });

    // newTask.taskId = docRef.id;

    _tasks.add(newTask);
    notifyListeners();
  }

  Future<void> deleteTask(int taskIndex) async {
    final task = _tasks[taskIndex];
    await _firestore.collection('tasks').doc(task.taskId).delete();
    _tasks.removeAt(taskIndex);
    notifyListeners();
  }

  bool getTaskValue(int taskIndex) {
    return _tasks[taskIndex].isCompleted;
  }

  Future<void> setTaskValue(Task task) async {
    final taskStatus = !task.isCompleted;
    await _firestore.collection('tasks').doc(task.taskId).update({
      'isCompleted': taskStatus
    });

    task.isCompleted = taskStatus;
    notifyListeners();
  }

  String getTaskTitle(int taskIndex) {
    return _tasks[taskIndex].title;
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