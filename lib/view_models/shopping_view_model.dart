import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/shopping_model.dart';

class ShoppingViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<ShoppingList> _shoppingLists = <ShoppingList>[];

  List<ShoppingList> get shoppingLists => List.unmodifiable(_shoppingLists);

  int get numShoppingLists => _shoppingLists.length;

  String shoppingListId = "";

  Future<void> loadShoppingLists() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      final groupId = await userDoc.data()?['groupId'];

      if (groupId == null) {
        return;
      }

      final shoppingListGroupQuery = FirebaseFirestore.instance
          .collection('shoppingLists')
          .where('groupId', isEqualTo: groupId)
          .get();

      final snapshot = await shoppingListGroupQuery;
      _shoppingLists.clear();

      for (var doc in snapshot.docs) {
        _shoppingLists.add(ShoppingList.fromMap(doc.id, doc.data()));
      }
    } catch (e) {
      print("Error loading shopping lists: $e");
    }
    notifyListeners();
  }

  Future<bool> createShoppingList(ShoppingList newShoppingList) async {
    try {
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
    } catch (e) {
      print("Error creating shopping list: $e");
    }
    notifyListeners();
    return true;
  }

  String getShoppingListTitle(int shoppingListIndex) {
    return _shoppingLists[shoppingListIndex].name;
  }

  Future<void> setItemValue(ShoppingList shoppingList, String itemId, bool newValue) async {
    try {
      final shoppingDoc =
          FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingList.shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        Map<String, dynamic>? currentItemsDetails;

        for (int i = 0; i < items.length; i++) {
          if (items[i]['itemId'] == itemId) {
            currentItemsDetails = items[i];

            //Remove the current item details (Firebase doesn't support directly updating specific items)
            await shoppingDoc.update({
              'items': FieldValue.arrayRemove([currentItemsDetails])
            });

            //New map with updated item details
            Map<String, dynamic> updatedItemDetails = {
              'isPurchased': newValue,
              'quantity': currentItemsDetails?['quantity'],
              'itemId': currentItemsDetails?['itemId'],
              'itemName': currentItemsDetails?['itemName']
            };

            //Updates the array with the new details
            await shoppingDoc.update({
              'items': FieldValue.arrayUnion([updatedItemDetails])
            });

            break;
          }
        }
      }
    } catch (e) {
      print("Error updating item: $e");
    }
    notifyListeners();
  }

  Future<void> deleteShoppingList(int shoppingListIndex) async {
    try {
      final shoppingList = _shoppingLists[shoppingListIndex];

      await _firestore.collection('shoppingLists').doc(shoppingList.shoppingListId).delete();
      _shoppingLists.removeAt(shoppingListIndex);
    } catch (e) {
      print("Error deleting shopping list: $e");
    }

    notifyListeners();
  }

  Future<void> deleteShoppingItem(ShoppingList shoppingList, String itemId) async {
    try {
      final shoppingDoc =
          FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingList.shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        Map<String, dynamic>? currentItemsDetails;

        for (int i = 0; i < items.length; i++) {
          if (items[i]['itemId'] == itemId) {
            currentItemsDetails = items[i];

            //Remove the current item details (Firebase doesn't support directly updating specific items)
            await shoppingDoc.update({
              'items': FieldValue.arrayRemove([currentItemsDetails])
            });
            break;
          }
        }
      }
    } catch (e) {
      print("Error deleting shopping item: $e");
    }
    notifyListeners();
  }

  Future<void> addNewShoppingItem(String shoppingListId, Map<String, dynamic> newItem) async {
    try {
      final shoppingDoc =
          FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        //Updates the array with the new details
        await shoppingDoc.update({
          'items': FieldValue.arrayUnion([newItem])
        });
      }
    } catch (e) {
      print("Error adding new shopping item: $e");
    }
    notifyListeners();
  }

  Future<int?> returnShoppingListLength(String shoppingListId) async {
    try {
      final shoppingDoc =
          FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        return items.length;
      }
    } catch (e) {
      print("Error retrieving shopping list length: $e");
    }
    return null;
  }

  Future<List<String>> returnShoppingListItemsNamesList(String shoppingListId) async {
    try {
      final shoppingDoc =
          FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        List<String> itemNames = [];

        for (int i = 0; i < items.length; i++) {
          itemNames.add(data['items'][i]['itemName']);
        }
        return itemNames;
      }
    } catch (e) {
      print("Error retrieving item names: $e");
    }
    return [];
  }

  Future<List<bool>> returnShoppingListItemsPurchaseStatusList(String shoppingListId) async {
    try {
      final shoppingDoc =
          FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        List<bool> itemStatuses = [];

        for (int i = 0; i < items.length; i++) {
          itemStatuses.add(data['items'][i]['isPurchased']);
        }
        return itemStatuses;
      }
    } catch (e) {
      print("Error retrieving item statuses: $e");
    }
    return [];
  }

  Future<List<String>> returnShoppingListItemsIdsList(String shoppingListId) async {
    try {
      final shoppingDoc =
          FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        List<String> itemIds = [];

        for (int i = 0; i < items.length; i++) {
          itemIds.add(data['items'][i]['itemId']);
        }
        return itemIds;
      }
    } catch (e) {
      print("Error retrieving item ids: $e");
    }
    return [];
  }

  Future<List<String>> returnShoppingListItemsQuantitiesList(String shoppingListId) async {
    try {
      final shoppingDoc =
          FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        List<String> itemQuantities = [];

        for (int i = 0; i < items.length; i++) {
          itemQuantities.add(data['items'][i]['quantity'].toString());
        }
        return itemQuantities;
      }
    } catch (e) {
      print("Error retrieving item quantities: $e");
    }
    return [];
  }

  Future<int?> returnShoppingListItemsIdsListLength(String shoppingListId) async {
    try {
      final shoppingDoc =
          FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        List<String> itemIds = [];

        for (int i = 0; i < items.length; i++) {
          itemIds.add(data['items'][i]['itemId']);
        }
        return itemIds.length;
      }
    } catch (e) {
      print("Error retrieving item ids length: $e");
    }
    return null;
  }

  Future<int?> returnShoppingListNotPurchasedItemsLength(String shoppingListId) async {
    try {
      final shoppingDoc =
          FirebaseFirestore.instance.collection('shoppingLists').doc(shoppingListId);
      final docSnapshot = await shoppingDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List items = data['items'];
        List<bool> itemIds = [];

        int numItemsNotPurchased = items.where((item) => item['isPurchased'] == false).length;
        return numItemsNotPurchased;
      }
    } catch (e) {
      print("Error retrieving item statuses: $e");
    }
    return null;
  }

  //Bottom sheet builder
  void displayBottomSheet(Widget bottomSheetView, BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        isScrollControlled: true,
        builder: ((context) {
          return bottomSheetView;
        }));
  }
}
