import 'package:uuid/uuid.dart';

class Expense {
  String expenseId;
  String expenseCreatorId;
  String name;
  num initialExpenseAmount;
  num remainingExpenseAmount;
  List<Map<String, dynamic>> assignedUsers = [];
  List<Map<String, dynamic>> assignedUsersRecords = [];

  Expense({
    required this.expenseId,
    required this.expenseCreatorId,
    required this.name,
    required this.initialExpenseAmount,
    required this.remainingExpenseAmount,
    required this.assignedUsers,
  });

  //Constructor for a new Expense
  Expense.newExpense(this.expenseCreatorId, this.name, this.initialExpenseAmount,
      this.remainingExpenseAmount, this.assignedUsers, this.assignedUsersRecords)
      : expenseId = '';

  //Factory constructor to create a Group from a Firestore document snapshot
  factory Expense.fromMap(String expenseId, Map<String, dynamic> map) {
    return Expense(
      expenseId: expenseId,
      expenseCreatorId: map['expenseCreatorId'],
      name: map['name'],
      initialExpenseAmount: map['initialExpenseAmount'],
      remainingExpenseAmount: map['remainingExpenseAmount'],
      assignedUsers: List<Map<String, dynamic>>.from(map['assignedUsers']),
    );
  }

  //Generates a random unique Id
  void generateId() {
    expenseId = const Uuid().v4();
  }
}
