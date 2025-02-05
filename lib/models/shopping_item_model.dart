import 'package:uuid/uuid.dart';

class ShoppingItem {
  String itemId;
  String title;
  bool isPurchased;

  //Constructor
  ShoppingItem({
    required this.itemId,
    required this.title,
    this.isPurchased = false
  });

  //Constructor for a new task
  ShoppingItem.newShoppingItem(this.title)
      : itemId = '',
        isPurchased = false;

  //Method that converts Task to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isPurchased': isPurchased
    };
  }

  //Factory constructor to create a task from a Firestore document snapshot
  factory ShoppingItem.fromMap(String itemId, Map<String, dynamic> map) {
    return ShoppingItem(
        itemId: itemId,
        title: map['title'],
        isPurchased: map['isPurchased'] ?? false
    );
  }

  void generateId() {
    itemId = Uuid().v4();
  }
}
