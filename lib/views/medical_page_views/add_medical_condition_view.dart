import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/medical_view_model.dart';
import 'package:shared_accommodation_management_app/views/medical_page_views/bottom_sheets/add_medical_condition_bottom_sheet_view.dart';

import '../../global/common/AppColours.dart';

class AddMedicalConditionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Consumer<MedicalViewModel>(builder: (context, viewModel, child) {
      return SizedBox(
        height: 60,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColours.colour3(brightness),
                foregroundColor: AppColours.colour1(brightness)
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