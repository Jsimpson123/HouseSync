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
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

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

final TextEditingController enteredShoppingListNameController = TextEditingController();
final TextEditingController enteredItemNameController = TextEditingController();

List<Map<String, dynamic>> addedItems = [];

List<TextEditingController> controllers = [];

bool isAddButtonEnabled() {
  return enteredShoppingListNameController.text.isNotEmpty;
}

bool isSubmitButtonEnabled() {
  return enteredShoppingListNameController.text.isNotEmpty &&
      addedItems.isNotEmpty;
}

FinanceViewModel financeViewModel = FinanceViewModel();

class _AddShoppingListBottomSheetView extends State<AddShoppingListBottomSheetView> {
  @override
  Widget build(BuildContext context) {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
      return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.only(
                bottom: isMobile
                    ? MediaQuery.of(context).viewInsets.bottom + 77
                    : MediaQuery.of(context).viewInsets.bottom),
            //Ensures the keyboard doesn't cover the textfields
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
                            : () async {
                                //If the required fields have data then create the expense
                                if (enteredShoppingListNameController
                                        .text.isNotEmpty &&
                                    addedItems.isNotEmpty) {
                                  ShoppingList newShoppingList =
                                      ShoppingList.newShoppingList(enteredShoppingListNameController.text, addedItems);

                                  //Sending data to the db
                                  await viewModel
                                      .createShoppingList(newShoppingList);

                                  addedItems.clear();

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
                                        builder: (context) => ShoppingPage()));
                              })
                  ],
                ))),
      );
    });
  }

  Future<void> assignItemsToShoppingListPopup(BuildContext context) async {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    int quantity = 1;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<FinanceViewModel>(
              builder: (context, viewModel, child) {
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                              decoration: const InputDecoration(
                                  hintText: "Item Name",
                                  border: OutlineInputBorder()),
                              controller: enteredItemNameController,
                              onSubmitted: (value) {
                              }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                padding: EdgeInsets.only(bottom: 30),
                                icon: const Icon(Icons.minimize),
                                iconSize: 60,
                                onPressed: () {
                                    if (enteredItemNameController.text.isNotEmpty && quantity < 21 && quantity > 1) {
                                      setStates(() {
                                        quantity--;
                                      });
                                    }
                                },
                              ),

                              Text(quantity.toString(),
                                style: const TextStyle(
                                    fontSize: 40
                                )
                              ),

                              IconButton(
                                icon: const Icon(Icons.add),
                                iconSize: 60,
                                onPressed: () {
                                    if (enteredItemNameController.text.isNotEmpty && quantity > 0 && quantity < 20) {
                                      setStates(() {
                                        quantity++;
                                      });
                                    }
                                    // else if (enteredItemNameController.text.isEmpty){
                                    //   showToast(message: "Please enter the item name to change the quantity");
                                    // }
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            color: Colors.green,
                              onPressed: () {
                                if (enteredItemNameController.text.isNotEmpty && quantity > 0 && quantity < 21) {
                                  setState(() {
                                    addedItems.add({
                                      'itemName': enteredItemNameController.text,
                                      'quantity': quantity,
                                      'isPurchased': false,
                                      'itemId': Uuid().v4()
                                    });
                                    showToast(
                                        message: "Added: $quantity ${enteredItemNameController.text}");
                                    enteredItemNameController.clear();
                                    setStates(() {
                                      quantity == 1;
                                    });
                                  });
                                }
                              },
                              icon: const Icon(Icons.check))
                        ],
                      )),
                    ),
                  ),
                ),
              );
            });
          });
        });
  }
}
