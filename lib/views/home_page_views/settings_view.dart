import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/main.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../global/common/AppColours.dart';

class SettingsView {
  static Future<void> settingsPopup(BuildContext context,
      SettingsView settingsView) async {
    User? user = FirebaseAuth.instance.currentUser;

    final brightness = Theme.of(context).brightness;
    
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Checks screen size to see if it is mobile or desktop
          double screenWidth = MediaQuery.of(context).size.width;
          bool isMobile = screenWidth < 600;
          return Consumer<GroupViewModel>(
              builder: (context, viewModel, child) {
                return AlertDialog(
                  scrollable: true,
                  title: Text('Settings'),
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
                                          borderRadius: const BorderRadius
                                              .vertical(
                                              top: Radius.circular(30),
                                              bottom: Radius.circular(30))),
                                    child: ListView(
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.password),
                                          title: Text('Change Password'),
                                          onTap: () {},
                                        ),
                                        Divider(),

                                        SwitchListTile(
                                          title: Text('Dark Mode'),
                                          secondary: Icon(Icons.dark_mode),
                                          value: MyApp.notifier.value == ThemeMode.dark,
                                          onChanged: (bool isOn) {
                                            MyApp.notifier.value = isOn ? ThemeMode.dark : ThemeMode.light;
                                          },
                                        ),
                                        Divider(),

                                        SizedBox(height: 40),

                                        Center(child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey))),
                                      ],
                                    )
                                    ,
                                  )
                              ),
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
}