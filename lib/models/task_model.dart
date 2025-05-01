import 'package:uuid/uuid.dart';

class Task {
  String taskId;
  String title;
  String? assignedUser;
  bool isCompleted;

  //Constructor
  Task(
      {required this.taskId,
      required this.title,
      required this.assignedUser,
      this.isCompleted = false});

  //Constructor for a new task
  Task.newTask(this.title)
      : taskId = '',
        assignedUser = null,
        isCompleted = false;

  //Factory constructor to create a task from a Firestore document snapshot
  factory Task.fromMap(String taskId, Map<String, dynamic> map) {
    return Task(
        taskId: taskId,
        title: map['title'],
        assignedUser: map['assignedUser'],
        isCompleted: map['isCompleted'] ?? false);
  }

  //Generates a random unique Id
  void generateId() {
    taskId = const Uuid().v4();
  }
}
