import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HouseSyncUser {
  String userId;
  String username;
  String email;
  String? groupId;
  List<String> assignedTasks;

  //Add required to the first three parameters - currently getting an error
  HouseSyncUser(
      {required this.userId,
      required this.username,
      required this.email,
        required this.assignedTasks,
      this.groupId,});

  //Constructor for a new User
  HouseSyncUser.newUser(this.username, this.email)
      : userId = '',
        groupId = '',
        assignedTasks = [];

  //Method that converts User to a map for database storage
  Map<String, dynamic> toMap() {
    return {'username': username, 'email': email, 'groupId': groupId};
  }

  //Factory constructor to create a User from a Firestore document snapshot
  factory HouseSyncUser.fromMap(
      String userId, String groupId, Map<String, dynamic> map) {
    return HouseSyncUser(
        userId: userId,
        username: map['username'],
        email: map['email'],
        groupId: map['groupId'],
        assignedTasks: List<String>.from(map['tasks'])
    );
  }
}
