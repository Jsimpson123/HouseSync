import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _members = <String>[];
  List<dynamic> _memberIds = <String>[];

  List<String> get members => _members;
  List<dynamic> get memberIds => _memberIds;

  String generateRandomGroupJoinCode() {
    String alphanumeric = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final Random random = Random();

    return List.generate(
        6, (index) => alphanumeric[random.nextInt(alphanumeric.length)]).join();
  }

  Future<bool> createGroup(String userId, String groupName, String groupCode) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get(); //Gets the userId from the users collection

      //Checks if the current user is already in a group and throws an exception if they are
      if (userDoc.exists && userDoc.data()?['groupId'] != null) {
        throw Exception("User is already in a group");
      }

      //Creates a group
      final groupRef = await _firestore.collection('groups').add({
        'name': groupName,
        'groupCode': groupCode,
        'members': [userId]
      });

      //Adds the current user to the group
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'groupId': groupRef.id});
    } catch (e) {
      print("Error creating group: $e");
    }

    notifyListeners();
    return true;
  }

  Future<bool> joinGroupViaCode(String userId, String inviteCode) async {
    try {
      //Query to search the groups collection for a document that has the same groupCode as the users entered one
      final query = await _firestore
          .collection('groups')
          .where('groupCode', isEqualTo: inviteCode)
          .get();

      //Checks that at least one group exists
      if (query.docs.isNotEmpty) {
        //Finds the first document with matching codes id
        final groupId = query.docs.first.id;

        //Updates the users groupId
        await _firestore
            .collection('users')
            .doc(userId)
            .update({'groupId': groupId});

        //Updates the members field of the group with the new member
        await _firestore.collection('groups').doc(groupId).update({
          'members': FieldValue.arrayUnion([userId])
        });

        return true;
      }
    } catch (e) {
      print("Error joining group: $e");
    }
      return false;
  }

  Future<bool> leaveGroup(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get(); //Gets the userId from the users collection

      final groupId = await userDoc.data()?['groupId'];

      //Checks if the current user is already in a group and removes them if they are
      if (userDoc.exists && groupId != null) {
        final groupDoc =
        FirebaseFirestore.instance.collection('groups').doc(groupId);
        final docSnapshot = await groupDoc.get();
        final data = docSnapshot.data();

        if (data != null) {
          await _firestore
              .collection('users')
              .doc(userId)
              .update({'groupId': FieldValue.delete()});
        }

        List members = docSnapshot.get('members');

        if (members.contains(userId) == true) {
          groupDoc.update({
            "members": FieldValue.arrayRemove([userId])
          });
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Error leaving group: $e");
    }
      return false;
  }

  Future<String?> returnGroupCode(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final groupId = await userDoc.data()?['groupId'];

    try {
    if (groupId != null) {
      final groupDoc = FirebaseFirestore.instance.collection('groups').doc(groupId);
      final docSnapshot = await groupDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        return data['groupCode'] as String?;
      }
    }
      } catch (e) {
        print("Error retrieving group code: $e");
      }
      notifyListeners();
      return null;
  }

  Future<String?> returnGroupName(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final groupId = await userDoc.data()?['groupId'];

    if (groupId != null) {
      try {
        final groupDoc =
            FirebaseFirestore.instance.collection('groups').doc(groupId);
        final docSnapshot = await groupDoc.get();
        final data = docSnapshot.data();

        if (data != null) {
          return data['name'] as String?;
        }
      } catch (e) {
        print("Error retrieving group code: $e");
      }
      notifyListeners();
    }
    return null;
  }

  Future<String?> returnGroupMembers(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final groupId = await userDoc.data()?['groupId'];

    if (groupId != null) {
      try {
        final groupDoc = FirebaseFirestore.instance.collection('groups').doc(groupId);
        final docSnapshot = await groupDoc.get();
        final data = docSnapshot.data();

        if (data != null) {
          List<dynamic> groupMembersIds = data['members'];
          List<String> groupMembersNames = [];

          for (int i = 0; i < groupMembersIds.length; i++) {
            final groupUserDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(groupMembersIds[i])
                .get();

              final groupMemberName = await groupUserDoc.data()?['username'];

              groupMembersNames.add(groupMemberName);
            }

          String groupMembersNamesFormatted = groupMembersNames
              .toString()
              .replaceAll("[", "")
              .replaceAll("]", "");
          return groupMembersNamesFormatted.toString();
        }
      } catch (e) {
        print("Error retrieving group members: $e");
      }
      notifyListeners();
    }
    return null;
  }

  Future<void> returnGroupMembersAsList(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final groupId = await userDoc.data()?['groupId'];

    List<String> groupMembersNames = [];
    List<dynamic> groupMembersIds = [];

    if (groupId != null) {
      try {
        final groupDoc = FirebaseFirestore.instance.collection('groups').doc(groupId);
        final docSnapshot = await groupDoc.get();
        final data = docSnapshot.data();

        if (data != null) {
           groupMembersIds = data['members'];

          //Removes the current user
          groupMembersIds.remove(userId);

          for (int i = 0; i < groupMembersIds.length; i++) {
            final groupUserDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(groupMembersIds[i])
                .get();

            final groupMemberName = await groupUserDoc.data()?['username'];

            groupMembersNames.add(groupMemberName);
          }
        }
      } catch (e) {
        print("Error retrieving group members: $e");
      }
    }
    _members = groupMembersNames;
    _memberIds = groupMembersIds;
    notifyListeners();
  }

  Future<void> returnAllGroupMembersAsList(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final groupId = await userDoc.data()?['groupId'];

    List<String> groupMembersNames = [];
    List<dynamic> groupMembersIds = [];

    if (groupId != null) {
      try {
        final groupDoc = FirebaseFirestore.instance.collection('groups').doc(groupId);
        final docSnapshot = await groupDoc.get();
        final data = docSnapshot.data();

        if (data != null) {
          groupMembersIds = data['members'];

          for (int i = 0; i < groupMembersIds.length; i++) {
            final groupUserDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(groupMembersIds[i])
                .get();

            final groupMemberName = await groupUserDoc.data()?['username'];

            groupMembersNames.add(groupMemberName);
          }
        }
      } catch (e) {
        print("Error retrieving group members: $e");
      }
    }
    _members = groupMembersNames;
    _memberIds = groupMembersIds;
    notifyListeners();
  }

  void removeMember(int index) {
    members.removeAt(index);
    memberIds.removeAt(index);
    notifyListeners();
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
