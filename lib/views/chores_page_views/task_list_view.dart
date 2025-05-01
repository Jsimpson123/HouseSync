import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';

import '../../global/common/AppColours.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() {
    return _TaskListViewState();
  }
}

class _TaskListViewState extends State<TaskListView> {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final User? user = FirebaseAuth.instance.currentUser;

    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
      return Container(
        decoration: BoxDecoration(
            color: AppColours.colour2(brightness),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
        child: viewModel.numTasks > 0 ?
        ListView.separated(
            padding: const EdgeInsets.all(15),
            separatorBuilder: (context, index) {
              return const SizedBox(height: 15);
            },
            itemCount: viewModel.numTasks,
            itemBuilder: (context, index) {
              final task = viewModel.tasks[index];
              return Dismissible(
                //Makes tasks dismissible via swiping
                key: UniqueKey(),
                onDismissed: (direction) {
                  viewModel.deleteTask(index);
                },
                background: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration:
                      BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Icon(Icons.delete)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColours.colour1(brightness), borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    key: Key("listtile$index"),
                    leading: Checkbox(
                        key: Key("checkbox$index"),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        side: BorderSide(width: 2, color: AppColours.colour3(brightness)),
                        checkColor: AppColours.colour1(brightness),
                        activeColor: AppColours.colour3(brightness),
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          viewModel.setTaskValue(task);
                        }),
                    title: Text(viewModel.getTaskTitle(index),
                        style: TextStyle(
                            color: AppColours.colour4(brightness), fontSize: 20, fontWeight: FontWeight.bold)),
                    trailing: task.assignedUser != null
                        ? IconButton(
                            key: Key("unassignButton$index"),
                            //If true
                            onPressed: () async {
                              bool userAssigned = await viewModel.unAssignCurrentUserFromTask(
                                  user!.uid, task.taskId, index);

                              setState(() {
                                if (userAssigned) {
                                  task.assignedUser = null;
                                }
                              });
                            },
                            icon: const Icon(Icons.remove_circle))
                        : IconButton(
                            key: Key("assignButton$index"),
                            //If false
                            onPressed: () async {
                              bool userUnassigned =
                                  await viewModel.assignCurrentUserToTask(user!.uid, task.taskId);

                              setState(() {
                                if (userUnassigned) {
                                  task.assignedUser = user.uid;
                                }
                              });
                            },
                            icon: const Icon(Icons.add_box)),
                    subtitle: task.assignedUser != null
                        ? Row(
                            children: [
                              Chip(
                                avatar: const Icon(Icons.account_box),
                                label: FutureBuilder<String?>(
                                    //If true
                                    future: viewModel.returnAssignedTaskUsername(task.taskId),
                                    builder:
                                        (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                      if ("${snapshot.data}" == "null") {
                                        return const Text(
                                            ""); //Due to a delay in the username loading
                                      } else {
                                        return Align(
                                          alignment: Alignment.bottomLeft,
                                          child: FittedBox(
                                            fit: BoxFit.fitHeight,
                                            child: Text("${snapshot.data}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColours.colour4(brightness))),
                                          ),
                                        );
                                      }
                                    }),
                                backgroundColor: brightness == Brightness.light
                                    ? Colors.lightBlue[100]
                                    : Colors.blue[900],
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ],
                          )
                        : null, //If false
                  ),
                ),
              );
            }) : const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cleaning_services_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "You're all caught up!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Tap the + button to add your first chore.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        )
      );
    });
  }
}
