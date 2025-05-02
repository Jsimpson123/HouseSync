import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';
import 'package:shared_accommodation_management_app/views/shopping_page_views/bottom_sheets/add_shopping_list_bottom_sheet_view.dart';

import '../../global/common/AppColours.dart';

class AddShoppingListView extends StatelessWidget {
  const AddShoppingListView({super.key});

  @override
  Widget build(BuildContext context) {
    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

    return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
      return SizedBox(
        height: 60,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColours.colour3(brightness),
                foregroundColor: AppColours.colour1(brightness)),
            onPressed: () {
              viewModel.displayBottomSheet(const AddShoppingListBottomSheetView(), context);
            },
            child: const Icon(Icons.add)),
      );
    });
  }
}
