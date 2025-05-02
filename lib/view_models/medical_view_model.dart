import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/medical_model.dart';

class MedicalViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<MedicalCondition> _medicalConditions = <MedicalCondition>[];

  List<MedicalCondition> get medicalConditions => List.unmodifiable(_medicalConditions);

  Future<void> loadMedicalConditions() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      final groupId = await userDoc.data()?['groupId'];

      if (groupId == null) {
        return;
      }

      final medicalGroupQuery = FirebaseFirestore.instance
          .collection('medicalConditions')
          .where('groupId', isEqualTo: groupId)
          .get();

      final snapshot = await medicalGroupQuery;
      _medicalConditions.clear();

      for (var doc in snapshot.docs) {
        _medicalConditions.add(MedicalCondition.fromMap(doc.id, doc.data()));
      }
    } catch (e) {
      print("Error loading conditions: $e");
    }
    notifyListeners();
  }

  Future<bool> createMedicalCondition(MedicalCondition newMedicalCondition) async {
    try {
      newMedicalCondition.generateId();

      User? user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      final groupId = await userDoc.data()?['groupId'];

      //Creates a medical conditon
      await _firestore
          .collection('medicalConditions')
          .doc(newMedicalCondition.medicalConditionId)
          .set({
        'medicalConditionCreatorId': newMedicalCondition.medicalConditionCreatorId,
        'name': newMedicalCondition.name,
        'description': newMedicalCondition.description,
        'groupId': groupId
      });

      //Updates the medicalConditions field of the user with the new condition
      await _firestore.collection('users').doc(user?.uid).update({
        'medicalConditions': FieldValue.arrayUnion([newMedicalCondition.medicalConditionId])
      });

      _medicalConditions.add(newMedicalCondition);
    } catch (e) {
      print("Error creating medical condition: $e");
    }
    notifyListeners();
    return true;
  }

  Future<void> addEmergencyContact(String userId, Map<String, dynamic> newContact) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        //Updates the array with the new details
        await userDoc.update({'emergencyContact': newContact});
      }
    } catch (e) {
      print("Error adding emergency contact: $e");
    }
    notifyListeners();
  }

  Future<void> deleteMedicalCondition(String conditionId) async {
    try {
      //Retrieves a condition
      final medicalDoc =
          await FirebaseFirestore.instance.collection('medicalConditions').doc(conditionId).get();

      final data = medicalDoc.data();

      if (medicalDoc.exists) {
        await FirebaseFirestore.instance.collection('medicalConditions').doc(conditionId).delete();

        String creatorId = data?['medicalConditionCreatorId'];

        final medicalUserDoc =
            await FirebaseFirestore.instance.collection('users').doc(creatorId).get();

        List userConditions = await medicalUserDoc.data()?['medicalConditions'];

        if (userConditions.contains(conditionId)) {
          await _firestore.collection('users').doc(medicalUserDoc.id).update({
            'medicalConditions': FieldValue.arrayRemove([conditionId])
          });
        }

        notifyListeners();
      }
    } catch (e) {
      print("Error deleting condition: $e");
    }
  }

  Future<List<String>> returnMedicalConditionsNamesList(String userId) async {
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
      print("Error retrieving condition names: $e");
    }
    return [];
  }

  Future<List<String>> returnMedicalConditionsDescsList(String userId) async {
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
      print("Error retrieving condition descriptions: $e");
    }
    return [];
  }

  Future<List<String>> returnMedicalConditionIds(String userId) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        List medicalConditions = data['medicalConditions'];
        List<String> conditionIds = [];

        for (int i = 0; i < medicalConditions.length; i++) {
          final medicalDoc = await FirebaseFirestore.instance
              .collection('medicalConditions')
              .doc(medicalConditions[i])
              .get();

          conditionIds.add(medicalDoc.id);
        }
        return conditionIds;
      }
    } catch (e) {
      print("Error retrieving condition ids: $e");
    }
    return [];
  }

  Future<String> returnUserEmergencyContactName(String userId) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        return data['emergencyContact']['contactName'];
      }
    } catch (e) {
      print("Error retrieving contact name: $e");
    }
    return "";
  }

  Future<String> returnUserEmergencyContactNumber(String userId) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final docSnapshot = await userDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        return data['emergencyContact']['contactNumber'];
      }
    } catch (e) {
      print("Error retrieving contact number: $e");
    }
    return "";
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
