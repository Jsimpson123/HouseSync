import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
import '../../view_models/finance_view_model.dart';
import 'bottom_sheets/add_expense_bottom_sheet_view.dart';

class AddExpenseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
      return SizedBox(
        height: 100,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: viewModel.colour3,
                foregroundColor: viewModel.colour1
            ),
            onPressed: () {
              viewModel.displayBottomSheet(
                  AddExpenseBottomSheetView(), context);
            },
            child: Icon(
                Icons.add)),
      );
    });
  }
}