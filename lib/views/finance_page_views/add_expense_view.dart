import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/common/AppColours.dart';
import '../../view_models/finance_view_model.dart';
import 'bottom_sheets/add_expense_bottom_sheet_view.dart';

class AddExpenseView extends StatelessWidget {
  const AddExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
      return SizedBox(
        height: 60,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColours.colour3(brightness),
                foregroundColor: AppColours.colour1(brightness)
            ),
            onPressed: () {
              viewModel.displayBottomSheet(
                  const AddExpenseBottomSheetView(), context);
            },
            child: const Icon(
                Icons.add)),
      );
    });
  }
}