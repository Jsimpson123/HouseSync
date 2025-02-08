// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_accommodation_management_app/models/shopping_item_model.dart';
// import 'package:shared_accommodation_management_app/models/task_model.dart';
// import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';
// import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
//
// class AddShoppingListItemsBottomSheetView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController enteredItemNameController = TextEditingController();
//
//     return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
//       return Padding(
//           padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context)
//                   .viewInsets
//                   .bottom), //Ensures the keyboard doesn't cover the textfields
//           child: Container(
//               height: 300,
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                       decoration: const InputDecoration(
//                           hintText: "Item Name", border: OutlineInputBorder()),
//                       controller: enteredItemNameController,
//                       onSubmitted: (value) async {
//                         if (enteredItemNameController.text.isNotEmpty) {
//                           ShoppingItem newItem = ShoppingItem.newShoppingItem(enteredItemNameController.text);
//                           await viewModel.addShoppingItem(newItem, viewModel.shoppingListId);
//                           enteredItemNameController.clear();
//                         }
//                         Navigator.of(context).pop(); //Makes bottom task bar disappear
//                       }
//                   ),
//                 ],
//               )));
//     });
//   }
// }
