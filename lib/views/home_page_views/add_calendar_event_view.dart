import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/home_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/bottom_sheets/add_calendar_event_bottom_sheet_view.dart';

class AddCalendarEventView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(builder: (context, viewModel, child) {
      return SizedBox(
        height: 60,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: viewModel.colour3,
                foregroundColor: viewModel.colour1
            ),
            onPressed: () {
              viewModel.displayBottomSheet(
                  AddCalendarEventBottomSheetView(), context);
            },
            child: Icon(
                Icons.add)),
      );
    });
  }
}