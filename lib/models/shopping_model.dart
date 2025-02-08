import 'package:uuid/uuid.dart';

class ShoppingList {
  String shoppingListId;
  String name;
  bool allItemsPurchased;
  List<Map<String, dynamic>> items = [];

  ShoppingList({
    required this.shoppingListId,
    required this.name,
    this.allItemsPurchased = false,
    required this.items
  });

  //Constructor for a new Shopping List
  ShoppingList.newShoppingList(
      this.name,
      this.items
  )
      : shoppingListId = '',
        allItemsPurchased = false;

  //Method that converts ShoppingList to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'items': items,
      'allItemsPurchased': allItemsPurchased
    };
  }

  //Factory constructor to create a Shopping List from a Firestore document snapshot
  factory ShoppingList.fromMap(String shoppingListId, Map<String, dynamic> map) {
    return ShoppingList(
        shoppingListId: shoppingListId,
        name: map['name'],
        allItemsPurchased: map['allItemsPurchased'] ?? false,
        items: List<Map<String, dynamic>>.from(map['items'])
    );
  }

  void generateId() {
    shoppingListId = Uuid().v4();
  }
}