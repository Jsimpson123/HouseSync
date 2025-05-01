import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
import '../../global/common/AppColours.dart';
import 'bottom_sheets/add_task_bottom_sheet_view.dart';

class AddTaskView extends StatelessWidget {
  const AddTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
      return SizedBox(
        height: 60,
        child: ElevatedButton(
          key: const Key("createChoreButton"),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColours.colour3(brightness),
                foregroundColor: AppColours.colour1(brightness)
            ),
            onPressed: () {
              viewModel.displayBottomSheet(
                  const AddTaskBottomSheetView(), context);
            },
            child: const Icon(
                Icons.add)),
      );
    });
  }
}