import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';

class DeleteTaskBottomSheetView extends StatelessWidget{
  const DeleteTaskBottomSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(builder: (context, viewModel, child){
      return Container(
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ElevatedButton(
              onPressed: () {
                viewModel.deleteAllTasks();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: viewModel.colour1,
                backgroundColor: viewModel.colour3,
                textStyle:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
              child: Text("Delete All")),

            SizedBox(width: 15),

            ElevatedButton(
                onPressed: () {
                  viewModel.deleteAllCompletedTasks();
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: viewModel.colour1,
                    backgroundColor: viewModel.colour3,
                    textStyle:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: Text("Delete Completed"))
          ],
        ),
      );
    });
  }
}