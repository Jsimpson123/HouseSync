import 'package:firebase_auth/firebase_auth.dart';
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
  int get numTasksRemaining => _tasks.where((task) => !task.isCompleted).length;

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

    _tasks.add(newTask);
    notifyListeners();
  }

  Future<void> deleteTask(int taskIndex) async {
    final task = _tasks[taskIndex];
    await _firestore.collection('tasks').doc(task.taskId).delete();
    _tasks.removeAt(taskIndex);
    notifyListeners();
  }

  Future<void> deleteAllTasks() async {
    final snapshot = await _firestore.collection('tasks').get();
    _tasks.clear();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    notifyListeners();
  }

  Future<void> deleteAllCompletedTasks() async {
    final collection = await _firestore.collection('tasks');
    final snapshot = await collection.where('isCompleted', isEqualTo: true).get();

      _tasks.removeWhere((task) => task.isCompleted);
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
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

  Future <String?> returnCurrentUsername () async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        final data = docSnapshot.data();

        if (data != null) {
          return data['username'] as String?;
        }
      } catch (e) {
        print("Error retrieving username: $e");
      }
    }
    return null;
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