import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/shopping_model.dart';
import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';

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
    return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: viewModel.colour2,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              padding: EdgeInsets.all(20),
              child: ListView.separated(
                  padding: EdgeInsets.all(15),
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 15);
                  },
                  scrollDirection: Axis.vertical,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: viewModel.shoppingLists.length,
                  itemBuilder: (context, index) {
                    final shoppingList = viewModel.shoppingLists[index];
                    return Container(
                        decoration: BoxDecoration(
                            color: viewModel.colour1,
                            borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          leading: Icon(Icons.shopping_cart),
                          title: Container(width: 50,
                            alignment: Alignment.bottomCenter,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Text(viewModel.getShoppingListTitle(index),
                                  style: TextStyle(
                                      color: viewModel.colour4,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          trailing: SizedBox(width: 100,
                            child: FutureBuilder<int?>(
                                future: viewModel.returnShoppingListLength(shoppingList.shoppingListId),
                                builder: (BuildContext context,
                                    AsyncSnapshot<int?> snapshot) {
                                  if ("${snapshot.data}" == "null") {
                                    return const Text(
                                        ""); //Due to a delay
                                  }
                                  else {
                                    return Align(
                                      alignment: Alignment.bottomRight,
                                      child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: Text(
                                            "Items: \n${snapshot.data}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: viewModel.colour4)),
                                      ),
                                    );
                                  }
                                }),
                          ),
                          onTap: () => shoppingListDetailsPopup(context, shoppingList),
                        )
                    );
                  }),
            ),
          ),
        ],
      );
    });
  }
  Future<void> shoppingListDetailsPopup(BuildContext context, ShoppingList shoppingList) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
            Future itemNamesFuture = viewModel.returnShoppingListItemsNamesList(shoppingList.shoppingListId);
            Future itemStatusesFuture = viewModel.returnShoppingListItemsPurchaseStatusList(shoppingList.shoppingListId);
            Future itemIdsFuture = viewModel.returnShoppingListItemsIdsList(shoppingList.shoppingListId);
            return StatefulBuilder(builder: (context, setStates) {
              return AlertDialog(
                scrollable: true,
                title: Text('Shopping List Details'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        child: Column(
                          children: <Widget>[
                        Container(
                          height: 50,
                        width: 800,
                        margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: Row(
                          children: [
                            //Total Tasks
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: viewModel.colour2, borderRadius: BorderRadius.circular(10)),
                                child: Column(children: [
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: 1, minHeight: 1),
                                          child: FutureBuilder<int?>(
                                                future: viewModel.returnShoppingListItemsIdsListLength(shoppingList.shoppingListId),
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
                                                        child: Text(
                                                            "${snapshot.data}",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.bold,
                                                                color: viewModel.colour4)),
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
                                        child: Text("Total Items", style: TextStyle(
                                            color: viewModel.colour4, fontWeight: FontWeight.w600
                                        ),),
                                      ),
                                    ),
                                  )
                                ]),
                              ),
                            ),

                            SizedBox(width: 20),

                            //Remaining Tasks
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: viewModel.colour2, borderRadius: BorderRadius.circular(10)),
                                child: Column(children: [
                                  Expanded(
                                    flex: 2,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: 1, minHeight: 1),
                                          child: FutureBuilder<int?>(
                                              future: viewModel.returnShoppingListNotPurchasedItemsLength(shoppingList.shoppingListId),
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
                                                      child: Text(
                                                          "${snapshot.data}",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: viewModel.colour4)),
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
                                        child: Text("Remaining items", style: TextStyle(
                                            color: viewModel.colour4, fontWeight: FontWeight.w600
                                        ),),
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
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: viewModel.colour2,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(30),
                                            bottom: Radius.circular(30))),

                                    child: FutureBuilder(
                                        future: Future.wait([itemNamesFuture, itemStatusesFuture, itemIdsFuture]),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<dynamic>> snapshot) {
                                          if ("${snapshot.data}" == "null") {
                                            return const Text(
                                                "");
                                          } else {
                                            return Expanded(
                                              child: ListView.separated(
                                                  padding: EdgeInsets.all(15),
                                                  shrinkWrap: true,
                                                  separatorBuilder: (context, index) {
                                                    return SizedBox(height: 15);
                                                  },
                                                  itemCount: snapshot.data?[0]!.length,
                                                  itemBuilder: (context, index) {
                                                    bool isChecked = snapshot.data?[1][index];
                                                    return Container(
                                                        decoration: BoxDecoration(
                                                            color: viewModel.colour1,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                20)),
                                                        child: ListTile(
                                                          leading: Checkbox(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(5)),
                                                              side: BorderSide(width: 2, color: viewModel.colour3),
                                                              checkColor: viewModel.colour1,
                                                              activeColor: viewModel.colour3,
                                                              value: isChecked,
                                                              onChanged: (bool? newValue) async {
                                                                setState(() {
                                                                  snapshot.data?[1][index] = newValue;
                                                                });
                                                                await viewModel.setItemValue(shoppingList, snapshot.data?[2][index], newValue!);
                                                              }),
                                                            title: Text(
                                                                snapshot.data?[0]![index],
                                                                style: TextStyle(
                                                                    color:
                                                                    viewModel.colour4,
                                                                    fontSize: 16)),
                                                        ));
                                                  }),
                                            );
                                          }
                                        })
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