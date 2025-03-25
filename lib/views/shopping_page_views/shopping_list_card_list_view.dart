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

    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Consumer<ShoppingViewModel>(builder: (context, viewModel, child) {
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: viewModel.colour2,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: GridView.builder(
                  padding: EdgeInsets.all(15),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: isMobile ? 0.8 : 2.7,
                  ),
                  scrollDirection: Axis.vertical,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: viewModel.shoppingLists.length,
                  itemBuilder: (context, index) {
                    final shoppingList = viewModel.shoppingLists[index];
                      return InkWell(
                        onTap: () => shoppingListDetailsPopup(context, shoppingList),
                        child: Container(
                            decoration: BoxDecoration(
                                color: viewModel.colour1,
                                borderRadius: BorderRadius.circular(20)),
                            child: Card(
                              color: Colors.white,

                              child:
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    IntrinsicHeight(
                                      child: Stack(
                                      children: [
                                        const Positioned(
                                          left: 0,
                                          child: Icon(
                                            Icons.shopping_cart,
                                            size: 30,
                                          ),
                                        ),
                                        Align(
                                          child: Text(viewModel.getShoppingListTitle(index),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: viewModel.colour4,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                )
                                    ),
                                    //Separating line
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     border: Border(
                                    //       bottom: BorderSide(color: Colors.black),
                                    //     ),
                                    //   ),
                                    // ),
                                    SizedBox(height: 30),
                                    Column(
                                      children: [
                                        Center(
                                          child: Text("Items:", style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: viewModel.colour4)),
                                        ),

                                        Center(
                                          child: FutureBuilder<int?>(
                                                  future: viewModel.returnShoppingListLength(shoppingList.shoppingListId),
                                                  builder: (BuildContext context,
                                                      AsyncSnapshot<int?> snapshot) {
                                                    if ("${snapshot.data}" == "null") {
                                                      return const Text(
                                                          ""); //Due to a delay
                                                    }
                                                    else {
                                                      return FittedBox(
                                                        fit: BoxFit.fitHeight,
                                                        child: Text("${snapshot.data}",
                                                            style: TextStyle(
                                                                fontSize: 24,
                                                                fontWeight: FontWeight.bold,
                                                                color: viewModel.colour4)),
                                                      );
                                                    }
                                                  }),
                                            ),

                                        SizedBox(height: 52),

                                        ElevatedButton(
                                          onPressed: () {
                                            viewModel.deleteShoppingList(index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              foregroundColor: viewModel.colour1,
                                              backgroundColor: Colors.red,
                                              textStyle:
                                              TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20))),
                                          child: const Text("Delete"))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ),
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
                    height: 400,
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
                            //Total Items
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

                            //Remaining Items
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
                              flex: 6,
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
                                                    return Dismissible(
                                                      //Makes items dismissible via swiping
                                                      key: UniqueKey(),
                                                      onDismissed: (direction) {
                                                        viewModel.deleteShoppingItem(shoppingList, snapshot.data?[2][index]);
                                                      },
                                                      background: Container(
                                                        margin: EdgeInsets.symmetric(horizontal: 5),
                                                        decoration: BoxDecoration(
                                                            color: Colors.red,
                                                            borderRadius: BorderRadius.circular(10)),
                                                        child: Center(child: Icon(Icons.delete)),
                                                      ),
                                                      child: Container(
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
                                                          )),
                                                    );
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