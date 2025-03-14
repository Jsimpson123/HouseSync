import 'package:uuid/uuid.dart';

class Expense {
  String expenseId;
  String expenseCreatorId;
  String name;
  num expenseAmount;
  List<Map<String, dynamic>> assignedUsers = [];

  Expense({
    required this.expenseId,
    required this.expenseCreatorId,
    required this.name,
    required this.expenseAmount,
    required this.assignedUsers
});

  //Constructor for a new Expense
  Expense.newExpense(
      this.expenseCreatorId,
      this.name,
      this.expenseAmount,
      this.assignedUsers)
      : expenseId = '';

  //Method that converts Expense to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'expenseCreatorId': expenseCreatorId,
      'name': name,
      'expenseAmount': expenseAmount,
      'assignedUsers': assignedUsers
    };
  }

  //Factory constructor to create a Group from a Firestore document snapshot
  factory Expense.fromMap(String expenseId, Map<String, dynamic> map) {
    return Expense(
        expenseId: expenseId,
        expenseCreatorId: map['expenseCreatorId'],
        name: map['name'],
        expenseAmount: map['expenseAmount'],
        assignedUsers: List<Map<String, dynamic>>.from(map['assignedUsers'])
    );
  }

  void generateId() {
    expenseId = Uuid().v4();
  }
}