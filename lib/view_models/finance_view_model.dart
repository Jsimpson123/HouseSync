import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/user_model.dart';

class FinanceViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Color colour1 = Colors.grey.shade50;
  Color colour2 = Colors.grey.shade200;
  Color colour3 = Colors.grey.shade800;
  Color colour4 = Colors.grey.shade900;

  double expenseAmount = 0;

  Future<bool> createExpense(String userId, String expenseName, expenseAmount, List<Map<String, dynamic>> assignedUsers) async {
    //Creates an expense
    final expenseRef = await _firestore.collection('expenses').add({
      'expenseCreatorId': userId,
      'name': expenseName,
      'expenseAmount': expenseAmount,
      'assignedUsers': assignedUsers
    });
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