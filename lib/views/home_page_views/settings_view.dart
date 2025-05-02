import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/main.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../global/common/AppColours.dart';
import '../../global/common/toast.dart';

class SettingsView {
  static Future<void> settingsPopup(BuildContext context, SettingsView settingsView) async {
    User? user = FirebaseAuth.instance.currentUser;

    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

    String? userEmail = user?.email;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Checks screen size to see if it is mobile or desktop
          double screenWidth = MediaQuery.of(context).size.width;
          bool isMobile = screenWidth < 600;
          return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Settings'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  height: isMobile ? 600 : 400,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            decoration: BoxDecoration(
                                color: AppColours.colour2(brightness),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(30), bottom: Radius.circular(30))),
                            child: ListView(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.password,
                                    color: AppColours.colour4(brightness),
                                  ),
                                  title: Text(
                                    'Change Password',
                                    style: TextStyle(color: AppColours.colour4(brightness)),
                                  ),
                                  onTap: () {
                                    sendForgotPasswordEmail(userEmail!);
                                  },
                                ),
                                const Divider(),
                                SwitchListTile(
                                  title: Text(
                                    'Dark Mode',
                                    style: TextStyle(color: AppColours.colour4(brightness)),
                                  ),
                                  secondary: Icon(
                                    Icons.dark_mode,
                                    color: AppColours.colour4(brightness),
                                  ),
                                  value: MyApp.notifier.value == ThemeMode.dark,
                                  onChanged: (bool isOn) async {
                                    MyApp.notifier.value = isOn ? ThemeMode.dark : ThemeMode.light;

                                    final user = FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .update({'darkMode': isOn});
                                    }
                                  },
                                ),
                                const Divider(),
                                const SizedBox(height: 40),
                                const Center(
                                    child: Text('HouseSync - Version 1.0.0',
                                        style: TextStyle(color: Colors.grey))),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  static void sendForgotPasswordEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showToast(message: "Reset password email sent");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast(message: "Invalid email");
      } else {
        showToast(message: "An error occurred: ${e.code}");
      }
    }
    return null;
  }
}
