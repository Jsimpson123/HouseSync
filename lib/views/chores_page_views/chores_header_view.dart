import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
import 'add_task_view.dart';
import 'bottom_sheets/delete_task_bottom_sheet_view.dart';

class ChoresHeaderView extends StatelessWidget {
  const ChoresHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(left: 15),
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
                                  color: viewModel.colour4)),
                        ),
                      ),
                    )
                  ],
                ),
              )),
          // Delete Icon
              Container(
                margin: EdgeInsets.only(right: 100),
                child: InkWell( onTap: () {
                  viewModel.displayBottomSheet(DeleteTaskBottomSheetView(), context);
                },
                child: Icon(Icons.delete, size: 40)),
              ),
        ],
      );
    });
  }
}
