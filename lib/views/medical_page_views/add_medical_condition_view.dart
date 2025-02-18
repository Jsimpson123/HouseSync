import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/medical_view_model.dart';
import 'package:shared_accommodation_management_app/views/medical_page_views/bottom_sheets/add_medical_condition_bottom_sheet_view.dart';

class AddMedicalConditionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalViewModel>(builder: (context, viewModel, child) {
      return SizedBox(
        height: 60,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: viewModel.colour3,
                foregroundColor: viewModel.colour1
            ),
            onPressed: () {
              viewModel.displayBottomSheet(
                  AddMedicalConditionBottomSheetView(), context);
            },
            child: Icon(
                Icons.add)),
      );
    });
  }
}