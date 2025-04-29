import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/user_view_model.dart';

class TaskListView extends StatefulWidget {
  @override
  State<TaskListView> createState() {
    return _TaskListViewState();
  }
}

class _TaskListViewState extends State<TaskListView> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
      return Container(
        decoration: BoxDecoration(
            color: viewModel.colour2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: viewModel.numTasks > 0 ?
        ListView.separated(
            padding: EdgeInsets.all(15),
            separatorBuilder: (context, index) {
              return SizedBox(height: 15);
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
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration:
                      BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Icon(Icons.delete)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: viewModel.colour1, borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    key: Key("listtile$index"),
                    leading: Checkbox(
                        key: Key("checkbox$index"),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        side: BorderSide(width: 2, color: viewModel.colour3),
                        checkColor: viewModel.colour1,
                        activeColor: viewModel.colour3,
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          viewModel.setTaskValue(task);
                        }),
                    title: Text(viewModel.getTaskTitle(index),
                        style: TextStyle(
                            color: viewModel.colour4, fontSize: 20, fontWeight: FontWeight.bold)),
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
                            icon: Icon(Icons.remove_circle))
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
                            icon: Icon(Icons.add_box)),
                    subtitle: task.assignedUser != null
                        ? Row(
                            children: [
                              Chip(
                                avatar: Icon(Icons.account_box),
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
                                                    color: viewModel.colour4)),
                                          ),
                                        );
                                      }
                                    }),
                                backgroundColor: Colors.lightBlue[100],
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            }) : Center(
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
