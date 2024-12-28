import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';

class TaskListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
      return Container(
        decoration: BoxDecoration(
            color: viewModel.colour2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: ListView.separated(
          padding: EdgeInsets.all(15),
            separatorBuilder: (context, index) {
              return SizedBox(height: 15);
            },
            itemCount: viewModel.numTasks,
            itemBuilder: (context, index) {
            final task = viewModel.tasks[index];
              return Dismissible( //Makes tasks dismissible via swiping
                key: UniqueKey(),
                onDismissed: (direction) {
                  viewModel.deleteTask(index);
                },
                background: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Icon(Icons.delete)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: viewModel.colour1,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      side: BorderSide(width: 2, color: viewModel.colour3),
                      checkColor: viewModel.colour1,
                      activeColor: viewModel.colour3,
                      value: task.isCompleted,
                      onChanged: (bool? value) {
                        viewModel.setTaskValue(task);
                      }
                    ),
                    title: Text(
                      viewModel.getTaskTitle(index),
                      style: TextStyle(
                          color: viewModel.colour4,
                          fontSize: 16)),
                  ),
                ),
              );
            }),
      );
    });
  }
}
