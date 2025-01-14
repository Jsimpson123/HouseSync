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

    User? user = FirebaseAuth.instance.currentUser;

    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];

    final taskGroupQuery = FirebaseFirestore.instance
        .collection('tasks')
        .where('groupId', isEqualTo: groupId)
        .get();


    final snapshot = await taskGroupQuery;
    _tasks.clear();


    for (var doc in snapshot.docs) {
      _tasks.add(Task.fromMap(doc.id, doc.data()));
    }
    notifyListeners();
  }

  Future<void> addTask(Task newTask) async {
    newTask.generateId();

    User? user = FirebaseAuth.instance.currentUser;

    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];

        await _firestore.collection('tasks').doc(newTask.taskId).set({
          'taskId': newTask.taskId,
          'title': newTask.title,
          'isCompleted': newTask.isCompleted,
          'groupId': groupId
        });

        _tasks.add(newTask);
        notifyListeners();
    }

  Future<void> deleteTask(int taskIndex) async {
    final task = _tasks[taskIndex];

    final userQuery = await _firestore
        .collection('users')
        .where('assignedTasks', arrayContains: task.taskId)
        .get();

    for (var doc in userQuery.docs) {
      //Updates the assignedTasks field by removing the taskId
      await doc.reference.update({
        'assignedTasks': FieldValue.arrayRemove([task.taskId])
      });
    }
    await _firestore.collection('tasks').doc(task.taskId).delete();
    _tasks.removeAt(taskIndex);

    // final userDoc = await _firestore
    //     .collection('users')
    //     .doc()
    //     .get(); //Gets the userId from the users collection
    //
    // final userDoc2 =
    // FirebaseFirestore.instance.collection('users').doc(userDoc.id);
    //
    // List userTasks = userDoc.get('assignedTasks');
    //
    // if (userTasks.contains(task.taskId) == true) {
    //   userDoc2.update({
    //     "assignedTasks": FieldValue.arrayRemove([task.taskId])
    //   });
    // }

    notifyListeners();
  }

  Future<void> deleteAllTasks() async {
    final snapshot = await _firestore.collection('tasks').get();
    _tasks.clear();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    final userSnapshot = await _firestore.collection('users').get();
    for (var doc in userSnapshot.docs) {
      await doc.reference.update({'assignedTasks': FieldValue.delete()});
    }

    notifyListeners();
  }

  Future<void> deleteAllCompletedTasks() async {
    final collection = await _firestore.collection('tasks');
    final snapshot = await collection.where('isCompleted', isEqualTo: true).get();

    List<String> completedTasksIds = [];

      _tasks.removeWhere((task) => task.isCompleted);
      for (var doc in snapshot.docs) {
        completedTasksIds.add(doc.id);
        await doc.reference.delete();
      }

      //Clears completed tasks from users 'assignedTasks' list when deleted
      if (completedTasksIds.isNotEmpty) {
        final userSnapshot = await _firestore.collection('users').get();
        for (var doc in userSnapshot.docs) {
          await doc.reference.update({'assignedTasks': FieldValue.arrayRemove(completedTasksIds)});
        }
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

  Future <bool> assignCurrentUserToTask (String userId, String taskId) async {

    //Updates the tasks assigned user
    await _firestore
        .collection('tasks')
        .doc(taskId)
        .update({'assignedUser': userId});

    //Updates the assignedTasks field of the user with the new task
    await _firestore.collection('users').doc(userId).update({
      'assignedTasks': FieldValue.arrayUnion([taskId])
    });

      notifyListeners();
      return true;
  }

  Future <bool> unAssignCurrentUserFromTask (String userId, String taskId) async {

    //Deletes the tasks assigned user
    await _firestore
        .collection('tasks')
        .doc(taskId)
        .update({'assignedUser': FieldValue.delete()});

    //Updates the assignedTasks field by removing the taskId
    await _firestore.collection('users').doc(userId).update({
      'assignedTasks': FieldValue.arrayRemove([taskId])
    });

    notifyListeners();
    return true;
  }

  Future <String?> returnAssignedTaskUserId (String taskId) async {
      try {
        final taskDoc = FirebaseFirestore.instance.collection('tasks').doc(taskId);
        final docSnapshot = await taskDoc.get();
        final data = docSnapshot.data();

        if (data != null) {
          return data['assignedUser'] as String?;
        }
      } catch (e) {
        print("Error retrieving username: $e");
      }
      return null;
    }

  Future <String?> returnAssignedTaskUsername (String taskId) async {
    try {
      final taskDoc = FirebaseFirestore.instance.collection('tasks').doc(taskId);
      final docSnapshot = await taskDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        String? userId = data['assignedUser'] as String?;

        if (userId!.isNotEmpty) {
          final query = await _firestore
              .collection('users')
              .where('userId', isEqualTo: userId)
              .get();

          // if (query.docs.isNotEmpty) {
            final userDoc = query.docs.first;
            return userDoc.data()['username'] as String?;
          // }
        }
      }
    } catch (e) {
      print("Error retrieving username: $e");
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