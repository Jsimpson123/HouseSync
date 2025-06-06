import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';
import 'package:shared_accommodation_management_app/models/finance_model.dart';

class FinanceViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Expense> _expenses = <Expense>[];

  List<Expense> get expenses => List.unmodifiable(_expenses);

  final List<Expense> _expenseRecords = <Expense>[];

  List<Expense> get expenseRecords => List.unmodifiable(_expenseRecords);

  int get numExpenses => _expenses.length;

  Future<void> loadExpenses() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      final groupId = await userDoc.data()?['groupId'];

      if (groupId == null) {
        return;
      }

      final expenseGroupQuery = FirebaseFirestore.instance
          .collection('expenses')
          .where('groupId', isEqualTo: groupId)
          .get();

      final snapshot = await expenseGroupQuery;
      _expenses.clear();

      for (var doc in snapshot.docs) {
        _expenses.add(Expense.fromMap(doc.id, doc.data()));
      }
    } catch (e) {
      print("Error loading expenses: $e");
    }
    notifyListeners();
  }

  Future<bool> createExpense(Expense newExpense) async {
    try {
      newExpense.generateId();

      User? user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      final groupId = await userDoc.data()?['groupId'];

      //Creates an expense
      await _firestore.collection('expenses').doc(newExpense.expenseId).set({
        'expenseCreatorId': newExpense.expenseCreatorId,
        'name': newExpense.name,
        'initialExpenseAmount': newExpense.initialExpenseAmount,
        'remainingExpenseAmount': newExpense.remainingExpenseAmount,
        'assignedUsers': newExpense.assignedUsers,
        'groupId': groupId
      });

      //Creates an expense record
      await _firestore.collection('expenseRecords').doc(newExpense.expenseId).set({
        'expenseCreatorId': newExpense.expenseCreatorId,
        'name': newExpense.name,
        'initialExpenseAmount': newExpense.initialExpenseAmount,
        'assignedUsersRecords': newExpense.assignedUsersRecords,
        'dateCreated': Timestamp.now(),
        'groupId': groupId
      });

      for (int i = 0; i < newExpense.assignedUsers.length; i++) {
        //Updates the assignedTasks field of the assigned users with the new expense
        await _firestore.collection('users').doc(newExpense.assignedUsers[i]['userId']).update({
          'assignedExpenses': FieldValue.arrayUnion([newExpense.expenseId])
        });
      }
      _expenses.add(newExpense);
    } catch (e) {
      print("Error creating expense: $e");
    }
    notifyListeners();
    return true;
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      //Retrieves an expense
      final expenseDoc =
          await FirebaseFirestore.instance.collection('expenses').doc(expenseId).get();

      final data = expenseDoc.data();

      if (expenseDoc.exists) {
        final expenseAmount = await expenseDoc.data()?['remainingExpenseAmount'];

        if (expenseAmount <= 0) {
          await FirebaseFirestore.instance.collection('expenses').doc(expenseId).delete();

          List assignedUsers = data?['assignedUsers'];
          List<dynamic> userIds = [];

          for (int i = 0; i < assignedUsers.length; i++) {
            userIds.add(data?['assignedUsers'][i]['userId']);

            final expenseUserDoc =
                await FirebaseFirestore.instance.collection('users').doc(userIds[i]).get();

            List assignedExpenses = await expenseUserDoc.data()?['assignedExpenses'];
            if (assignedExpenses.contains(expenseId)) {
              await _firestore.collection('users').doc(userIds[i]).update({
                'assignedExpenses': FieldValue.arrayRemove([expenseId])
              });
            }
          }
          //Prevents duplicate toast message
          Fluttertoast.cancel();
          showToast(message: "The whole expense has been paid off!");
        }
      }
    } catch (e) {
      print("Error deleting expense: $e");
    }
    notifyListeners();
    return true;
  }

  Future<void> deleteExpenseUponClick(int expenseIndex) async {
    try {
      final expense = _expenses[expenseIndex];

      //Retrieves an expense
      final expenseDoc =
          await FirebaseFirestore.instance.collection('expenses').doc(expense.expenseId).get();

      final data = expenseDoc.data();

      if (expenseDoc.exists) {
        await FirebaseFirestore.instance.collection('expenses').doc(expense.expenseId).delete();

        List assignedUsers = data?['assignedUsers'];
        List<dynamic> userIds = [];

        for (int i = 0; i < assignedUsers.length; i++) {
          userIds.add(data?['assignedUsers'][i]['userId']);

          final expenseUserDoc =
              await FirebaseFirestore.instance.collection('users').doc(userIds[i]).get();

          List assignedExpenses = await expenseUserDoc.data()?['assignedExpenses'];
          if (assignedExpenses.contains(expense.expenseId)) {
            await _firestore.collection('users').doc(userIds[i]).update({
              'assignedExpenses': FieldValue.arrayRemove([expense.expenseId])
            });
          }
        }
      }
      _expenses.removeAt(expenseIndex);
    } catch (e) {
      print("Error deleting expense: $e");
    }

    notifyListeners();
  }

  String getExpenseTitle(int expenseIndex) {
    return _expenses[expenseIndex].name;
  }

  Future<List<String>> returnAssignedExpenseUsernamesList(String expenseId) async {
    try {
      final taskDoc = FirebaseFirestore.instance.collection('expenses').doc(expenseId);
      final docSnapshot = await taskDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List assignedUsers = data['assignedUsers'];
        List<dynamic> userIds = [];
        List<String> assignedUserNames = [];

        for (int i = 0; i < assignedUsers.length; i++) {
          userIds.add(data['assignedUsers'][i]['userId']);

          final expenseUserDoc =
              await FirebaseFirestore.instance.collection('users').doc(userIds[i]).get();

          final expenseMemberName = await expenseUserDoc.data()?['username'];

          assignedUserNames.add(expenseMemberName);
        }
        return assignedUserNames;
      }
    } catch (e) {
      print("Error retrieving usernames: $e");
    }
    return [];
  }

  Future<List> returnAssignedExpenseUserIdsList(String expenseId) async {
    try {
      final taskDoc = FirebaseFirestore.instance.collection('expenses').doc(expenseId);
      final docSnapshot = await taskDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List assignedUsers = data['assignedUsers'];
        List<dynamic> userIds = [];

        for (int i = 0; i < assignedUsers.length; i++) {
          userIds.add(data['assignedUsers'][i]['userId']);
        }
        return userIds;
      }
    } catch (e) {
      print("Error retrieving UserIds: $e");
    }
    return [];
  }

  Future<List> returnAssignedUsersAmountOwedList(String expenseId) async {
    try {
      final taskDoc = FirebaseFirestore.instance.collection('expenses').doc(expenseId);
      final docSnapshot = await taskDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List assignedUsers = data['assignedUsers'];
        List<dynamic> amounts = [];

        for (int i = 0; i < assignedUsers.length; i++) {
          amounts.add(data['assignedUsers'][i]['amount'].toString());
        }
        return amounts;
      }
    } catch (e) {
      print("Error retrieving amounts: $e");
    }
    return [];
  }

  Future<num?> returnAssignedExpenseAmount(String expenseId) async {
    try {
      final taskDoc = FirebaseFirestore.instance.collection('expenses').doc(expenseId);
      final docSnapshot = await taskDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        num expenseAmount = data['remainingExpenseAmount'];

        return expenseAmount;
      }
    } catch (e) {
      print("Error retrieving Amount: $e");
    }
    return null;
  }

  Future<String?> returnExpenseCreatorId(String expenseId) async {
    try {
      final expenseDoc = FirebaseFirestore.instance.collection('expenses').doc(expenseId);
      final docSnapshot = await expenseDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        String expenseCreator = data['expenseCreatorId'];

        if (expenseCreator.isNotEmpty) {
          return expenseCreator;
        }
      }
    } catch (e) {
      print("Error retrieving expense creator Id: $e");
    }
    return null;
  }

  Future<String?> returnExpenseCreatorName(String expenseId) async {
    try {
      final expenseDoc = FirebaseFirestore.instance.collection('expenses').doc(expenseId);
      final docSnapshot = await expenseDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        String expenseCreator = data['expenseCreatorId'];

        final userDoc = FirebaseFirestore.instance.collection('users').doc(expenseCreator);
        final docSnapshot = await userDoc.get();
        final userData = docSnapshot.data();

        String expenseCreatorName = userData?['username'];

        if (expenseCreatorName.isNotEmpty) {
          return expenseCreatorName;
        }
      }
    } catch (e) {
      print("Error retrieving expense creator name: $e");
    }
    return null;
  }

  Future<String?> returnExpenseRecordCreatorName(String expenseId) async {
    try {
      final expenseDoc = FirebaseFirestore.instance.collection('expenseRecords').doc(expenseId);
      final docSnapshot = await expenseDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        String expenseCreator = data['expenseCreatorId'];

        final userDoc = FirebaseFirestore.instance.collection('users').doc(expenseCreator);
        final docSnapshot = await userDoc.get();
        final userData = docSnapshot.data();

        String expenseCreatorName = userData?['username'];

        if (expenseCreatorName.isNotEmpty) {
          return expenseCreatorName;
        }
      }
    } catch (e) {
      print("Error retrieving expense creator name: $e");
    }
    return null;
  }

  Future<void> updateUserAmountPaid(String expenseId, String userId, num amountPaid) async {
    try {
      final expenseDoc = FirebaseFirestore.instance.collection('expenses').doc(expenseId);
      final docSnapshot = await expenseDoc.get();
      final data = docSnapshot.data();

      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

      final expenseRecordDoc =
          FirebaseFirestore.instance.collection('expenseRecords').doc(expenseId);
      final docRecordSnapshot = await expenseRecordDoc.get();
      final recordData = docRecordSnapshot.data();

      if (data != null) {
        List assignedUsers = data['assignedUsers'];
        num totalAmount = data['remainingExpenseAmount'];

        Map<String, dynamic> currentUserExpenseDetails;

        for (int i = 0; i < assignedUsers.length; i++) {
          if (assignedUsers[i]['userId'] == userId) {
            //Retrieves the users expense details and assigns it to a map
            currentUserExpenseDetails = assignedUsers[i];

            num? userAmount = assignedUsers[i]['amount'];

            //Updates the total expense amount
            await expenseDoc.update({'remainingExpenseAmount': totalAmount - amountPaid});

            //Remove the current user expense details (Firebase doesn't support directly updating specific items)
            await expenseDoc.update({
              'assignedUsers': FieldValue.arrayRemove([currentUserExpenseDetails])
            });

            if (amountPaid != userAmount && amountPaid < userAmount!) {
              //New map with updated user expense details
              Map<String, dynamic> updatedUserExpenseDetails = {
                'userId': userId,
                'amount': (userAmount - amountPaid)
              };

              //Updates the array with the new details
              await expenseDoc.update({
                'assignedUsers': FieldValue.arrayUnion([updatedUserExpenseDetails])
              });

              showToast(message: "You paid off £$amountPaid!");
            } else if (amountPaid == userAmount) {
              await userDoc.update({
                'assignedExpenses': FieldValue.arrayRemove([expenseId])
              });

              showToast(message: "You paid off your expense!");
            }
            notifyListeners();
          }
        }
      }

      if (recordData != null) {
        List assignedUsers = recordData['assignedUsersRecords'];

        Map<String, dynamic> currentUserRecord;

        for (int i = 0; i < assignedUsers.length; i++) {
          if (assignedUsers[i]['userId'] == userId) {
            //Retrieves the users expense details and assigns it to a map
            currentUserRecord = assignedUsers[i];

            List payments = currentUserRecord['payments'];
            num remainingAmount = currentUserRecord['remainingAmountOwed'];
            num initialAmount = currentUserRecord['initialAmountOwed'];
            String userName = currentUserRecord['userName'];

            Map<String, dynamic> entry = {'amountPaid': amountPaid, 'datePaid': Timestamp.now()};

            //Remove the current user expense details (Firebase doesn't support directly updating specific items)
            await expenseRecordDoc.update({
              'assignedUsersRecords': FieldValue.arrayRemove([currentUserRecord])
            });

            payments.add(entry);

            Map<String, dynamic> updatedUserExpenseRecordDetails;

            if (amountPaid != remainingAmount && amountPaid < remainingAmount) {
              //New map with updated user expense details
              updatedUserExpenseRecordDetails = {
                'userId': userId,
                'userName': userName,
                'initialAmountOwed': initialAmount,
                'remainingAmountOwed': remainingAmount - amountPaid,
                'paidOff': false,
                'payments': payments
              };

              //Updates the array with the new details
              await expenseRecordDoc.update({
                'assignedUsersRecords': FieldValue.arrayUnion([updatedUserExpenseRecordDetails])
              });
            } else {
              updatedUserExpenseRecordDetails = {
                'userId': userId,
                'userName': userName,
                'initialAmountOwed': initialAmount,
                'remainingAmountOwed': remainingAmount - amountPaid,
                'paidOff': true,
                'payments': payments
              };
              //Updates the array with the new details
              await expenseRecordDoc.update({
                'assignedUsersRecords': FieldValue.arrayUnion([updatedUserExpenseRecordDetails])
              });
            }
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print("Error updating user amount: $e");
    }
  }

  Future<List> returnExpenseRecordPayments(String expenseId, String userId) async {
    try {
      final expenseDoc =
          await FirebaseFirestore.instance.collection('expenseRecords').doc(expenseId).get();

      final data = expenseDoc.data();
      List assignedUsersRecords = data?['assignedUsersRecords'];

      List<Map<String, dynamic>> allPayments = [];

      for (int i = 0; i < assignedUsersRecords.length; i++) {
        if (assignedUsersRecords[i]['userId'] == userId) {
          List payments = await assignedUsersRecords[i]['payments'];

          //Gets payments from each users records
          for (int j = 0; j < payments.length; j++) {
            allPayments.add(payments[j]);
          }
        }
      }
      return allPayments;
    } catch (e) {
      print("Error returning record payments: $e");
    }
    return [];
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
