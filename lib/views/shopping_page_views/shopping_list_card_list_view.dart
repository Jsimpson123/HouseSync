import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/shopping_model.dart';
import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';
import 'package:shared_accommodation_management_app/views/shopping_page_views/bottom_sheets/add_shopping_list_bottom_sheet_view.dart';
import 'package:uuid/uuid.dart';

import '../../global/common/AppColours.dart';
import '../../global/common/toast.dart';

class ShoppingListCardListView extends StatefulWidget {
  const ShoppingListCardListView({super.key});

  @override
  State<ShoppingListCardListView> createState() {
    return _ShoppingListCardListView();
  }
}

class _ShoppingListCardListView extends State<ShoppingListCardListView> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
      return Column(
        children: [
          Expanded(
            child: Container(
                decoration: BoxDecoration(
                    color: AppColours.colour2(brightness),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
                child: viewModel.shoppingLists.isNotEmpty
                    ? GridView.builder(
                        padding: const EdgeInsets.all(15),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: isMobile ? 0.8 : 2.7,
                        ),
                        scrollDirection: Axis.vertical,
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: viewModel.shoppingLists.length,
                        itemBuilder: (context, index) {
                          final shoppingList = viewModel.shoppingLists[index];
                          return InkWell(
                            onTap: () => shoppingListDetailsPopup(context, shoppingList),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: AppColours.colour1(brightness),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Card(
                                  color: brightness == Brightness.light
                                      ? Colors.white
                                      : AppColours.colour1(brightness),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        IntrinsicHeight(
                                            child: Stack(
                                          children: [
                                            Positioned(
                                              left: 0,
                                              child: Icon(
                                                Icons.shopping_cart_outlined,
                                                size: isMobile ? 20 : 30,
                                              ),
                                            ),
                                            Align(
                                              child: Text(viewModel.getShoppingListTitle(index),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: AppColours.colour4(brightness),
                                                      fontSize: isMobile ? 20 : 24,
                                                      fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        )),
                                        const SizedBox(height: 30),
                                        Column(
                                          children: [
                                            Center(
                                              child: Text("Items:",
                                                  style: TextStyle(
                                                      fontSize: isMobile ? 20 : 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColours.colour4(brightness))),
                                            ),
                                            Center(
                                              child: FutureBuilder<int?>(
                                                  future: viewModel.returnShoppingListLength(
                                                      shoppingList.shoppingListId),
                                                  builder: (BuildContext context,
                                                      AsyncSnapshot<int?> snapshot) {
                                                    if ("${snapshot.data}" == "null") {
                                                      return const Text(""); //Due to a delay
                                                    } else {
                                                      return FittedBox(
                                                        fit: BoxFit.fitHeight,
                                                        child: Text("${snapshot.data}",
                                                            style: TextStyle(
                                                                fontSize: isMobile ? 20 : 24,
                                                                fontWeight: FontWeight.bold,
                                                                color: AppColours.colour4(
                                                                    brightness))),
                                                      );
                                                    }
                                                  }),
                                            ),
                                            SizedBox(height: isMobile ? 25 : 52),
                                            ElevatedButton(
                                                onPressed: () {
                                                  viewModel.deleteShoppingList(index);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    foregroundColor: AppColours.colour1(brightness),
                                                    backgroundColor: Colors.red,
                                                    textStyle: const TextStyle(
                                                        fontWeight: FontWeight.w700, fontSize: 16),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20))),
                                                child: const Text("Delete"))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          );
                        })
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "There are currently no created shopping lists!",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Tap the + button to add your first shopping list.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )),
          ),
        ],
      );
    });
  }

  Future<void> shoppingListDetailsPopup(BuildContext context, ShoppingList shoppingList) async {
    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
            Future itemNamesFuture =
                viewModel.returnShoppingListItemsNamesList(shoppingList.shoppingListId);
            Future itemStatusesFuture =
                viewModel.returnShoppingListItemsPurchaseStatusList(shoppingList.shoppingListId);
            Future itemIdsFuture =
                viewModel.returnShoppingListItemsIdsList(shoppingList.shoppingListId);
            Future itemQuantitiesFuture =
                viewModel.returnShoppingListItemsQuantitiesList(shoppingList.shoppingListId);
            return StatefulBuilder(builder: (context, setStates) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Shopping List Details'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: isMobile ? 600 : 400,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 800,
                              margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                              child: Row(
                                children: [
                                  //Total Items
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: AppColours.colour2(brightness),
                                          borderRadius: BorderRadius.circular(10)),
                                      child: Column(children: [
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(minWidth: 1, minHeight: 1),
                                                child: FutureBuilder<int?>(
                                                    future: viewModel
                                                        .returnShoppingListItemsIdsListLength(
                                                            shoppingList.shoppingListId),
                                                    builder: (BuildContext context,
                                                        AsyncSnapshot<int?> snapshot) {
                                                      if ("${snapshot.data}" == "null") {
                                                        return const Text(
                                                            ""); //Due to a delay in the number loading
                                                      } else {
                                                        return Align(
                                                          alignment: Alignment.bottomLeft,
                                                          child: FittedBox(
                                                            fit: BoxFit.fitHeight,
                                                            child: Text("${snapshot.data}",
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: AppColours.colour4(
                                                                        brightness))),
                                                          ),
                                                        );
                                                      }
                                                    }),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                "Total Items",
                                                style: TextStyle(
                                                    color: AppColours.colour4(brightness),
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        )
                                      ]),
                                    ),
                                  ),

                                  const SizedBox(width: 20),

                                  //Remaining Items
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: AppColours.colour2(brightness),
                                          borderRadius: BorderRadius.circular(10)),
                                      child: Column(children: [
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(minWidth: 1, minHeight: 1),
                                                child: FutureBuilder<int?>(
                                                    future: viewModel
                                                        .returnShoppingListNotPurchasedItemsLength(
                                                            shoppingList.shoppingListId),
                                                    builder: (BuildContext context,
                                                        AsyncSnapshot<int?> snapshot) {
                                                      if ("${snapshot.data}" == "null") {
                                                        return const Text(
                                                            ""); //Due to a delay in the number loading
                                                      } else {
                                                        return Align(
                                                          alignment: Alignment.bottomLeft,
                                                          child: FittedBox(
                                                            fit: BoxFit.fitHeight,
                                                            child: Text("${snapshot.data}",
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: AppColours.colour4(
                                                                        brightness))),
                                                          ),
                                                        );
                                                      }
                                                    }),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Align(
                                            alignment: Alignment.topCenter,
                                            child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                "Remaining items",
                                                style: TextStyle(
                                                    color: AppColours.colour4(brightness),
                                                    fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        )
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                flex: 6,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColours.colour2(brightness),
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(30), bottom: Radius.circular(30))),
                                    child: FutureBuilder(
                                        future: Future.wait([
                                          itemNamesFuture,
                                          itemStatusesFuture,
                                          itemIdsFuture,
                                          itemQuantitiesFuture
                                        ]),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<dynamic>> snapshot) {
                                          if ("${snapshot.data}" == "null") {
                                            return const Text("");
                                          } else {
                                            return Expanded(
                                                child: snapshot.data?[0]!.length > 0
                                                    ? ListView.separated(
                                                        padding: const EdgeInsets.all(15),
                                                        shrinkWrap: true,
                                                        separatorBuilder: (context, index) {
                                                          return const SizedBox(height: 15);
                                                        },
                                                        itemCount: snapshot.data?[0]!.length,
                                                        itemBuilder: (context, index) {
                                                          bool isChecked = snapshot.data?[1][index];
                                                          return Dismissible(
                                                            //Makes items dismissible via swiping
                                                            key: UniqueKey(),
                                                            onDismissed: (direction) {
                                                              viewModel.deleteShoppingItem(
                                                                  shoppingList,
                                                                  snapshot.data?[2][index]);
                                                            },
                                                            background: Container(
                                                              margin: const EdgeInsets.symmetric(
                                                                  horizontal: 5),
                                                              decoration: BoxDecoration(
                                                                  color: Colors.red,
                                                                  borderRadius:
                                                                      BorderRadius.circular(10)),
                                                              child: const Center(
                                                                  child: Icon(Icons.delete)),
                                                            ),
                                                            child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: AppColours.colour1(
                                                                        brightness),
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: ListTile(
                                                                  leading: SizedBox(
                                                                    width: isMobile ? 30 : 40,
                                                                    child: Align(
                                                                      alignment:
                                                                          Alignment.centerLeft,
                                                                      child: Checkbox(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                                  borderRadius:
                                                                                      BorderRadius
                                                                                          .circular(
                                                                                              5)),
                                                                          side: BorderSide(
                                                                              width: 2,
                                                                              color: AppColours
                                                                                  .colour3(
                                                                                      brightness)),
                                                                          checkColor: AppColours
                                                                              .colour1(brightness),
                                                                          activeColor:
                                                                              AppColours.colour3(
                                                                                  brightness),
                                                                          value: isChecked,
                                                                          onChanged: (bool?
                                                                              newValue) async {
                                                                            setState(() {
                                                                              snapshot.data?[1]
                                                                                      [index] =
                                                                                  newValue;
                                                                            });
                                                                            await viewModel
                                                                                .setItemValue(
                                                                                    shoppingList,
                                                                                    snapshot.data?[
                                                                                        2][index],
                                                                                    newValue!);
                                                                          }),
                                                                    ),
                                                                  ),
                                                                  trailing: SizedBox(
                                                                    width: isMobile ? 40 : 60,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment.end,
                                                                      children: [
                                                                        Icon(
                                                                          Icons.shopping_bag,
                                                                          size: isMobile ? 16 : 24,
                                                                        ),
                                                                        Text(
                                                                            snapshot
                                                                                .data?[3]![index],
                                                                            style: TextStyle(
                                                                                color: AppColours
                                                                                    .colour4(
                                                                                        brightness),
                                                                                fontSize: isMobile
                                                                                    ? 14
                                                                                    : 16)),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  title: SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Text(
                                                                      snapshot.data?[0]![index],
                                                                      style: TextStyle(
                                                                          color: AppColours.colour4(
                                                                              brightness),
                                                                          fontSize:
                                                                              isMobile ? 14 : 16),
                                                                      softWrap: false,
                                                                    ),
                                                                  ),
                                                                )),
                                                          );
                                                        })
                                                    : const Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                          children: [
                                                            Icon(Icons.shopping_basket_sharp,
                                                                size: 60, color: Colors.grey),
                                                            SizedBox(height: 16),
                                                            Text(
                                                              "There are currently no added items.",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                            SizedBox(height: 8),
                                                            Text(
                                                              "Tap the + button if you wish to add an item.",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                  fontSize: 14, color: Colors.grey),
                                                            ),
                                                          ],
                                                        ),
                                                      ));
                                          }
                                        }))),
                            const SizedBox(
                              height: 15,
                            ),
                            Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
                              return SizedBox(
                                height: 60,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColours.colour3(brightness),
                                        foregroundColor: AppColours.colour1(brightness)),
                                    onPressed: () {
                                      addAdditionalItemsToShoppingListPopup(context, shoppingList);
                                    },
                                    child: const Icon(Icons.add)),
                              );
                            })
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

  Future<void> addAdditionalItemsToShoppingListPopup(
      BuildContext context, ShoppingList shoppingList) async {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    int quantity = 1;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
            return StatefulBuilder(builder: (context, setStates) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Add Items'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: 230,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                              decoration: const InputDecoration(
                                  hintText: "Item Name", border: OutlineInputBorder()),
                              controller: enteredItemNameController,
                              onSubmitted: (value) {}),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                padding: const EdgeInsets.only(bottom: 30),
                                icon: const Icon(Icons.minimize),
                                iconSize: 60,
                                onPressed: () {
                                  if (enteredItemNameController.text.isNotEmpty &&
                                      quantity < 21 &&
                                      quantity > 1) {
                                    setStates(() {
                                      quantity--;
                                    });
                                  }
                                },
                              ),
                              Text(quantity.toString(), style: const TextStyle(fontSize: 40)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                iconSize: 60,
                                onPressed: () {
                                  if (enteredItemNameController.text.isNotEmpty &&
                                      quantity > 0 &&
                                      quantity < 20) {
                                    setStates(() {
                                      quantity++;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          IconButton(
                              color: Colors.green,
                              iconSize: isMobile ? 50 : 60,
                              onPressed: () {
                                if (enteredItemNameController.text.isNotEmpty &&
                                    quantity > 0 &&
                                    quantity < 21) {
                                  setState(() {
                                    Map<String, dynamic> newItem = ({
                                      'itemName': enteredItemNameController.text,
                                      'quantity': quantity,
                                      'isPurchased': false,
                                      'itemId': const Uuid().v4()
                                    });
                                    viewModel.addNewShoppingItem(
                                        shoppingList.shoppingListId, newItem);
                                    showToast(
                                        message:
                                            "Added: $quantity ${enteredItemNameController.text}");
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
