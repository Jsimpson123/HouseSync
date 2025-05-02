import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/task_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Task> _tasks = <Task>[];

  List<Task> get tasks => List.unmodifiable(_tasks);

  int get numTasks => _tasks.length;

  int get numTasksRemaining => _tasks.where((task) => !task.isCompleted).length;

  Future<void> loadTasks() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      final groupId = await userDoc.data()?['groupId'];

      if (groupId == null) {
        return;
      }

      final taskGroupQuery =
          FirebaseFirestore.instance.collection('tasks').where('groupId', isEqualTo: groupId).get();

      final snapshot = await taskGroupQuery;
      _tasks.clear();

      for (var doc in snapshot.docs) {
        _tasks.add(Task.fromMap(doc.id, doc.data()));
      }
    } catch (e) {
      print("Error loading tasks: $e");
    }
    notifyListeners();
  }

  Future<void> addTask(Task newTask) async {
    try {
      newTask.generateId();

      User? user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      final groupId = await userDoc.data()?['groupId'];

      await _firestore.collection('tasks').doc(newTask.taskId).set({
        'taskId': newTask.taskId,
        'title': newTask.title,
        'isCompleted': newTask.isCompleted,
        'groupId': groupId
      });
    } catch (e) {
      print("Error adding task: $e");
    }
    _tasks.add(newTask);
    notifyListeners();
  }

  Future<void> deleteTask(int taskIndex) async {
    try {
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
    } catch (e) {
      print("Error deleting task: $e");
    }

    notifyListeners();
  }

  Future<void> deleteAllTasks() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      _tasks.clear();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      final userSnapshot = await _firestore.collection('users').get();
      for (var doc in userSnapshot.docs) {
        await doc.reference.update({'assignedTasks': FieldValue.delete()});
      }
    } catch (e) {
      print("Error deleting all tasks: $e");
    }

    notifyListeners();
  }

  Future<void> deleteAllCompletedTasks() async {
    try {
      final collection = _firestore.collection('tasks');
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
    } catch (e) {
      print("Error deleting all completed tasks: $e");
    }
    notifyListeners();
  }

  bool getTaskValue(int taskIndex) {
    return _tasks[taskIndex].isCompleted;
  }

  Future<void> setTaskValue(Task task) async {
    try {
      final taskStatus = !task.isCompleted;
      await _firestore.collection('tasks').doc(task.taskId).update({'isCompleted': taskStatus});

      task.isCompleted = taskStatus;
    } catch (e) {
      print("Error setting task value: $e");
    }
    notifyListeners();
  }

  String getTaskTitle(int taskIndex) {
    return _tasks[taskIndex].title;
  }

  Future<bool> assignCurrentUserToTask(String userId, String taskId) async {
    try {
      //Updates the tasks assigned user
      await _firestore.collection('tasks').doc(taskId).update({'assignedUser': userId});

      //Updates the assignedTasks field of the user with the new task
      await _firestore.collection('users').doc(userId).update({
        'assignedTasks': FieldValue.arrayUnion([taskId])
      });
    } catch (e) {
      print("Error assigning current user to task: $e");
    }

    notifyListeners();
    return true;
  }

  Future<bool> unAssignCurrentUserFromTask(String userId, String taskId, int taskIndex) async {
    try {
      //Deletes the tasks assigned user
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update({'assignedUser': FieldValue.delete()});

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
    } catch (e) {
      print("Error unassigning current user from task: $e");
    }

    notifyListeners();
    return true;
  }

  Future<String?> returnAssignedTaskUserId(String taskId) async {
    try {
      final taskDoc = FirebaseFirestore.instance.collection('tasks').doc(taskId);
      final docSnapshot = await taskDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        return data['assignedUser'] as String?;
      }
    } catch (e) {
      print("Error retrieving user Id: $e");
    }
    return null;
  }

  Future<String?> returnAssignedTaskUsername(String taskId) async {
    try {
      final taskDoc = FirebaseFirestore.instance.collection('tasks').doc(taskId);
      final docSnapshot = await taskDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        String? userId = data['assignedUser'] as String?;

        if (userId!.isNotEmpty) {
          final query =
              await _firestore.collection('users').where('userId', isEqualTo: userId).get();

          final userDoc = query.docs.first;
          return userDoc.data()['username'] as String?;
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
        isScrollControlled: true,
        builder: ((context) {
          return bottomSheetView;
        }));
  }
}
