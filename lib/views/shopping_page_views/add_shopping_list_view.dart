import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';
import 'package:shared_accommodation_management_app/views/shopping_page_views/bottom_sheets/add_shopping_list_bottom_sheet_view.dart';

class AddShoppingListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
      return SizedBox(
        height: 60,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: viewModel.colour3,
                foregroundColor: viewModel.colour1
            ),
            onPressed: () {
              viewModel.displayBottomSheet(
                  AddShoppingListBottomSheetView(), context);
            },
            child: Icon(
                Icons.add)),
      );
    });
  }
}