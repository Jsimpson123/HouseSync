import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/medical_model.dart';
import 'package:shared_accommodation_management_app/views/finance_page_views/bottom_sheets/add_expense_bottom_sheet_view.dart';

class MedicalViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<MedicalCondition> _medicalConditions = <MedicalCondition>[];
  List<MedicalCondition> get medicalConditions => List.unmodifiable(_medicalConditions);

  int get numMedicalConditions => _medicalConditions.length;

  Color colour1 = Colors.grey.shade50;
  Color colour2 = Colors.grey.shade200;
  Color colour3 = Colors.grey.shade800;
  Color colour4 = Colors.grey.shade900;

  Future <void> loadMedicalConditions() async {
    User? user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];

    final medicalGroupQuery = FirebaseFirestore.instance
        .collection('medicalConditions')
        .where('groupId', isEqualTo: groupId)
        .get();

    final snapshot = await medicalGroupQuery;
    _medicalConditions.clear();

    for (var doc in snapshot.docs) {
      _medicalConditions.add(MedicalCondition.fromMap(doc.id, doc.data()));
    }
    notifyListeners();
  }

  Future<bool> createMedicalCondition(MedicalCondition newMedicalCondition) async {
    newMedicalCondition.generateId();

    User? user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];

    //Creates a shopping list
    await _firestore.collection('medicalConditions').doc(newMedicalCondition.medicalConditionId).set({
      'medicalConditionCreatorId': newMedicalCondition.medicalConditionCreatorId,
      'name': newMedicalCondition.name,
      'description': newMedicalCondition.description,
      'groupId': groupId
    });

    //Updates the assignedTasks field of the user with the new task
    await _firestore.collection('users').doc(user?.uid).update({
      'medicalConditions': FieldValue.arrayUnion([newMedicalCondition.medicalConditionId])
    });

    _medicalConditions.add(newMedicalCondition);
    notifyListeners();
    return true;
  }

  Future <List<String>> returnMedicalConditionsNamesList (String userId) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List medicalConditions = data['medicalConditions'];
        List<String> conditionNames = [];

        for (int i = 0; i < medicalConditions.length; i++) {
          final medicalDoc = await FirebaseFirestore.instance
              .collection('medicalConditions')
              .doc(medicalConditions[i])
              .get();

          final medicalConditionName = await medicalDoc.data()?['name'];

          conditionNames.add(medicalConditionName);
        }
        return conditionNames;
      }
    } catch (e) {
      print("Error retrieving item names: $e");
    }
    return [];
  }

  Future <List<String>> returnMedicalConditionsDescsList (String userId) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List medicalConditions = data['medicalConditions'];
        List<String> conditionDescs = [];

        for (int i = 0; i < medicalConditions.length; i++) {
          final medicalDoc = await FirebaseFirestore.instance
              .collection('medicalConditions')
              .doc(medicalConditions[i])
              .get();

          final medicalConditionDesc = await medicalDoc.data()?['description'];

          conditionDescs.add(medicalConditionDesc);
        }
        return conditionDescs;
      }
    } catch (e) {
      print("Error retrieving item descriptions: $e");
    }
    return [];
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