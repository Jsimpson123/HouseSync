import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';
import 'package:shared_accommodation_management_app/models/group_model.dart';

class GroupViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Group> _groups = <Group>[];
  Group? _currentGroup;

  List<Group> get groups => List.unmodifiable(_groups);
  Group? get currentGroup => _currentGroup;

  Future<void> createGroup(String userId, String groupName) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists && userDoc.data()?['groupId'] != null) {
      throw Exception("User is already in a group");
      showToast(message: "User is already in a group");
    }

    //Creates a group
    final groupRef = await _firestore.collection('groups').add({
      'name': groupName,
      'members': [userId]
    });

    //Adds the current user to the group
    await _firestore.collection('users').doc(userId).update({
      'groupId': groupRef.id
    });

    notifyListeners();
  }
}