import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';
import 'package:shared_accommodation_management_app/models/group_model.dart';

class GroupViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Group> _groups = <Group>[];
  Group? _currentGroup;

  List<Group> get groups => List.unmodifiable(_groups);
  Group? get currentGroup => _currentGroup;

  Color colour1 = Colors.grey.shade50;
  Color colour2 = Colors.grey.shade200;
  Color colour3 = Colors.grey.shade800;
  Color colour4 = Colors.grey.shade900;

  String generateRandomGroupJoinCode() {
    String alphanumeric = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final Random random = Random();

    return List.generate(6, (index) => alphanumeric[random.nextInt(alphanumeric.length)]).join();
  }

  Future<bool> createGroup(String userId, String groupName, String groupCode) async {
    final userDoc = await _firestore.collection('users').doc(userId).get(); //Gets the userId from the users collection
    //Checks if the current user is already in a group and throws an exception if they are
    if (userDoc.exists && userDoc.data()?['groupId'] != null) {
      throw Exception("User is already in a group");
      showToast(message: "User is already in a group");
    }

    //Creates a group
    final groupRef = await _firestore.collection('groups').add({
      'name': groupName,
      'groupCode': groupCode,
      'members': [userId]
    });

    //Adds the current user to the group
    await _firestore.collection('users').doc(userId).update({
      'groupId': groupRef.id
    });

    notifyListeners();
    return true;
  }

  Future<bool> joinGroupViaCode(String userId, String inviteCode) async {
    //Query to search the groups collection for a document that has the same groupCode as the users entered one
    final query = await _firestore.collection('groups')
        .where('groupCode', isEqualTo: inviteCode)
        .get();

    //Checks that at least one group exists
    if(query.docs.isNotEmpty) {
      //Finds the first document with matching codes id
      final groupId = query.docs.first.id;

      //Updates the users groupId
      await _firestore.collection('users').doc(userId).update({
        'groupId': groupId
      });

      //Updates the members field of the group with the new member
      await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([userId])
      });

      return true;
    } else {
      return false;
    }
  }

  Future <String?> returnGroupCode (String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final groupId = await userDoc.data()?['groupId'];

    if (groupId!=null) {
      try {
        final groupDoc = FirebaseFirestore.instance.collection('groups').doc(groupId);
        final docSnapshot = await groupDoc.get();
        final data = docSnapshot.data();

        if (data != null) {
          return data['groupCode'] as String?;
        }
      } catch (e) {
        print("Error retrieving group code: $e");
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