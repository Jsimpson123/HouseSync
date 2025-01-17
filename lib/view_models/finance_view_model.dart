import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/user_model.dart';

class FinanceViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Color colour1 = Colors.grey.shade50;
  Color colour2 = Colors.grey.shade200;
  Color colour3 = Colors.grey.shade800;
  Color colour4 = Colors.grey.shade900;

  Future<bool> createExpense(String userId, String expenseName, double expenseAmount, List<String> assignedUsers) async {
    //Creates an expense
    final groupRef = await _firestore.collection('expenses').add({
      'expenseCreatorId': userId,
      'name': expenseName,
      'expenseAmount': expenseAmount,
      'assignedUsers': assignedUsers
    });

    // //Adds the current user to the group
    // await _firestore
    //     .collection('users')
    //     .doc(userId)
    //     .update({'groupId': groupRef.id});

    notifyListeners();
    return true;
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