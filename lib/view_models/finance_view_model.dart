import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/finance_model.dart';
import 'package:shared_accommodation_management_app/models/user_model.dart';

class FinanceViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Expense> _expenses = <Expense>[];
  List<Expense> get expenses => List.unmodifiable(_expenses);

  Color colour1 = Colors.grey.shade50;
  Color colour2 = Colors.grey.shade200;
  Color colour3 = Colors.grey.shade800;
  Color colour4 = Colors.grey.shade900;

  Future <void> loadExpenses() async {
    User? user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];

    final expenseGroupQuery = FirebaseFirestore.instance
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .get();

    final snapshot = await expenseGroupQuery;
    _expenses.clear();

    for (var doc in snapshot.docs) {
      _expenses.add(Expense.fromMap(doc.id, doc.data()));
    }
    notifyListeners();
  }

  Future<bool> createExpense(Expense newExpense) async {
    newExpense.generateId();

    User? user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];

    print(newExpense.assignedUsers);

    //Creates an expense
    await _firestore.collection('expenses').doc(newExpense.expenseId).set({
      'expenseCreatorId': newExpense.expenseCreatorId,
      'name': newExpense.name,
      'expenseAmount': newExpense.expenseAmount,
      'assignedUsers': newExpense.assignedUsers,
      'groupId': groupId
    });

    print(newExpense.assignedUsers);

    _expenses.add(newExpense);
    notifyListeners();
    return true;
  }

  //This and the following methods will be used to display expense data in some sort of card
  Future<String?> returnExpenseName(String expenseId) async {
    //Retrieves an expense
    final expenseDoc = await FirebaseFirestore.instance.collection('expenses').doc(expenseId).get();

    if (expenseDoc.exists) {
      try {
        final expenseName = await expenseDoc.data()?['name'];
        final data = expenseName.data();

        if (data != null) {
          return data['name'] as String?;
        }
      } catch (e) {
        print("Error retrieving expense name: $e");
      }
      notifyListeners();
    }
    return null;
  }

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