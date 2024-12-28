import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../global/common/toast.dart';
import '../models/user_model.dart';

class FirebaseAuthFunctionality {
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Future<User?> signUpWithEmailAndPassword(String email, String password) async {
  //   try {
  //     UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
  //     return credential.user;
  //   } on FirebaseAuthException catch (e) {
  //     if(e.code == 'email-already-in-use') {
  //       showToast(message: "The email is already in use");
  //     } else if(e.code == 'invalid-email') {
  //       showToast(message: 'invalid email');
  //     }else {
  //       showToast(message: "An error occurred: ${e.code}");
  //     }
  //   }
  //   return null;
  // }

  Future<void> registerUser(HouseSyncUser user, String password) async {
    try {
      if (user.username.isNotEmpty) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: user.email, password: password);

        String? userId = userCredential.user?.uid;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({'username': user.username, 'email': user.email});
      }

      if (user.username.isEmpty) {
        showToast(message: 'Username must not be empty');
      } else if (password.isEmpty) {
        showToast(message: 'Password must not be empty');
      } else if (password.length < 6) {
        showToast(message: 'Password must be at least 6 characters long');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: "The email is already in use");
      } else if (e.code == 'invalid-email') {
        showToast(message: 'invalid email');
      } else {
        showToast(message: "An error occurred: ${e.code}");
      }
    }
    return;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: "Incorrect email or password");
      } else {
        showToast(message: "An error occurred: ${e.code}");
      }
    }
    return null;
  }
}
