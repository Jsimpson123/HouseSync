import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/shopping_item_model.dart';
import 'package:shared_accommodation_management_app/models/shopping_model.dart';

class ShoppingViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<ShoppingList> _shoppingLists = <ShoppingList>[];
  List<ShoppingList> get shoppingLists => List.unmodifiable(_shoppingLists);

  final List<ShoppingItem> _items = <ShoppingItem>[];
  List<ShoppingItem> get shoppingItems => List.unmodifiable(_items);

  String shoppingListId = "";

  int get numItems => _items.length;

  Color colour1 = Colors.grey.shade50;
  Color colour2 = Colors.grey.shade200;
  Color colour3 = Colors.grey.shade800;
  Color colour4 = Colors.grey.shade900;

  Future <void> loadShoppingLists() async {
    User? user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];

    final shoppingListGroupQuery = FirebaseFirestore.instance
        .collection('shoppingLists')
        .where('groupId', isEqualTo: groupId)
        .get();

    final snapshot = await shoppingListGroupQuery;
    _shoppingLists.clear();

    for (var doc in snapshot.docs) {
      _shoppingLists.add(ShoppingList.fromMap(doc.id, doc.data()));
    }
    notifyListeners();
  }

  Future<bool> createShoppingList(ShoppingList newShoppingList) async {
    newShoppingList.generateId();

    User? user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];

    //Creates a shopping list
    await _firestore.collection('shoppingLists').doc(newShoppingList.shoppingListId).set({
      'name': newShoppingList.name,
      'items': newShoppingList.items,
      'allItemsPurchased': newShoppingList.allItemsPurchased,
      'groupId': groupId
    });

    shoppingListId = newShoppingList.shoppingListId;
    _shoppingLists.add(newShoppingList);
    notifyListeners();
    return true;
  }

  String getShoppingListTitle(int shoppingListIndex) {
    return _shoppingLists[shoppingListIndex].name;
  }

  Future <int?> returnShoppingListLength (String shoppingListId) async {
    try {
      final shoppingDoc = FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        return items.length;
      }
    } catch (e) {
      print("Error retrieving items length: $e");
    }
    return null;
  }

  Future <List<String>> returnShoppingListItemsList (String shoppingListId) async {
    try {
      final shoppingDoc = FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        // List<dynamic> userIds = [];
        List<String> itemNames = [];

        for (int i = 0; i < items.length; i++) {
          itemNames.add(data['items'][i]['itemName']);

          // final expenseUserDoc = await FirebaseFirestore.instance
          //     .collection('users')
          //     .doc(userIds[i])
          //     .get();

          // final expenseMemberName = await expenseUserDoc.data()?['username'];
          //
          // assignedUserNames.add(expenseMemberName);
        }
        return itemNames;
      }
    } catch (e) {
      print("Error retrieving item names: $e");
    }
    return [];
  }

  // Future<void> addShoppingItem(ShoppingItem newItem, String shoppingListId) async {
  //   newItem.generateId();
  //
  //   await _firestore.collection('shoppingLists').doc(shoppingListId)
  //       .collection('shoppingListItems').add({
  //   'itemId': newItem.itemId,
  //   'title': newItem.title,
  //   'isPurchased': newItem.isPurchased,
  //   });
  //
  //   _items.add(newItem);
  //   notifyListeners();
  // }

  //Bottom sheet builder
  void displayBottomSheet(Widget bottomSheetView, BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: ((context) {
          return bottomSheetView;
        }));
  }
}