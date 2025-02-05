import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';
import 'package:shared_accommodation_management_app/models/finance_model.dart';
import 'package:shared_accommodation_management_app/pages/finance_page.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';
import 'package:shared_accommodation_management_app/views/shopping_page_views/bottom_sheets/add_shopping_list_items_bottom_sheet_view.dart';

import '../../../models/shopping_model.dart';
import '../../../view_models/finance_view_model.dart';
import '../../../view_models/task_view_model.dart';

class AddShoppingListBottomSheetView extends StatefulWidget {
  const AddShoppingListBottomSheetView({super.key});

  @override
  State<AddShoppingListBottomSheetView> createState() {
    return _AddShoppingListBottomSheetView();
  }
}

GroupViewModel groupViewModel = GroupViewModel();

User? user = FirebaseAuth.instance.currentUser;

final TextEditingController enteredShoppingListNameController =
TextEditingController();
// final TextEditingController enteredExpenseAmountController =
// TextEditingController();

List<TextEditingController> controllers = [];

bool isAddButtonEnabled() {
  return enteredShoppingListNameController.text.isNotEmpty;
}

bool isSubmitButtonEnabled() {
  return enteredShoppingListNameController.text.isNotEmpty;

}

FinanceViewModel financeViewModel = FinanceViewModel();

class _AddShoppingListBottomSheetView extends State<AddShoppingListBottomSheetView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
      return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), //Ensures the keyboard doesn't cover the textfields
          child: Container(
              height: 300,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  //ExpenseName
                  TextField(
                      decoration: const InputDecoration(
                          hintText: "Shopping List Name",
                          border: OutlineInputBorder()),
                      controller: enteredShoppingListNameController,
                      onChanged: (_) => setState(() {})),

                  SizedBox(height: 15),

                  // Expanded(
                  //   flex: 2,
                  //   child: Align(
                  //     alignment: Alignment.center,
                  //     child: FittedBox(
                  //       child: Text(
                  //         "$totalAmountOwed",
                  //         style: TextStyle(
                  //             fontSize: 28,
                  //             color: viewModel.colour3,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  //Assign items Button
                  IconButton(
                      icon: Icon(Icons.shopping_basket),
                      iconSize: 30,
                      onPressed: !isAddButtonEnabled()
                          ? null
                          : () => assignItemsToShoppingListPopup(context)),

                  SizedBox(height: 10),

                  //Submit Button
                  ElevatedButton(
                      child: Text("Submit"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: viewModel.colour3,
                          foregroundColor: viewModel.colour1,
                          fixedSize: Size(150, 100)),
                      onPressed: !isSubmitButtonEnabled()
                          ? null
                          : ()  async {
                        //If the required fields have data then create the expense
                        if (enteredShoppingListNameController.text.isNotEmpty)
                        {
                          ShoppingList newShoppingList = ShoppingList.newShoppingList(enteredShoppingListNameController.text);

                          //Sending data to the db
                          await viewModel.createShoppingList(newShoppingList);

                          setState(() {
                            //Resets everything to ensure values don't remain when creating a new expense
                            Navigator.of(context).pop();
                            enteredShoppingListNameController.clear();
                            controllers.clear();
                          });
                        }

                        //Refreshes the page to allow users to be visible again when assigning
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ShoppingPage()));
                      })
                ],
              )));
    });
  }

  Future<void> assignItemsToShoppingListPopup(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {

            return StatefulBuilder(builder: (context, setStates) {
              return AlertDialog(
                scrollable: true,
                title: Text('Add Items'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: viewModel.colour2,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(30),
                                            bottom: Radius.circular(30))),
                                  child: SizedBox(
                                    height: 60,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: viewModel.colour3,
                                            foregroundColor: viewModel.colour1
                                        ),
                                        onPressed: () {
                                          viewModel.displayBottomSheet(
                                              AddShoppingListItemsBottomSheetView(), context);
                                        },
                                        child: Icon(
                                            Icons.add)),
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
          });
        });
  }
}
