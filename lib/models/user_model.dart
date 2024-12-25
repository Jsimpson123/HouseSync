import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HouseSyncUser {
  String username;
  String email;
  String password;

  HouseSyncUser(this.username, this.email, this.password);

  // Future<void> registerUser(String username, String email, String password) async {
  //   UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password);
  //
  //   String? userId = userCredential.user?.uid;
  //
  //   await FirebaseFirestore.instance.collection('users').doc(userId).set({
  //     'username': username,
  //     'email': email
  //   });
  // }
}