import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
import '../../global/common/AppColours.dart';
import 'bottom_sheets/delete_task_bottom_sheet_view.dart';

class ChoresHeaderView extends StatelessWidget {
  const ChoresHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: IconButton(
              icon: const Icon(
                Icons.menu,
                size: 42,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          const SizedBox(
            width: 25,
          ),
          const Icon(
            Icons.cleaning_services,
            size: 45,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text("Chores",
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: AppColours.colour4(brightness))),
                      ),
                    ),
                  )
                ],
              )),
          // Delete Icon
          Container(
            margin: const EdgeInsets.only(right: 100),
            child: InkWell(
                onTap: () {
                  viewModel.displayBottomSheet(const DeleteTaskBottomSheetView(), context);
                },
                child: const Icon(Icons.delete, size: 40)),
          ),
        ],
      );
    });
  }
}
