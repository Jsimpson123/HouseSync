import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/pages/home_page.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/user_view_model.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/side_bar.dart';

import '../../view_models/home_view_model.dart';
import '../../view_models/task_view_model.dart';
import 'bottom_sheets/create_group_bottom_sheet_view.dart';

class HomeHeaderView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    GroupViewModel groupViewModel = GroupViewModel();
    User? user = FirebaseAuth.instance.currentUser;

    return Consumer<UserViewModel>(builder: (context, viewModel, child) {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(left: 15),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text("Welcome",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                  color: viewModel.colour4)),
                        ),
                      ),
                    ),
                    FutureBuilder<String?>(
                        future: viewModel.returnCurrentUsername(),
                        builder: (BuildContext context,
                            AsyncSnapshot<String?> snapshot) {
                          if ("${snapshot.data}" == "null") {
                            return const Text(
                                ""); //Due to a delay in the username loading
                          } else {
                            return Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Text("${snapshot.data}",
                                      style: TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: viewModel.colour4)),
                                ),
                              ),
                            );
                          }
                        }),
                  ],
                ),
              )),
          FutureBuilder<String?>(
              future: groupViewModel.returnGroupCode(user!.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<String?> snapshot) {
                if ("${snapshot.data}" == "null") {
                  return const Text(
                      ""); //Due to a delay in the group code loading
                } else {
                  return Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text("Group Code: \n${snapshot.data}",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: viewModel.colour4)),
                      ),
                    ),
                  );
                }
              }),
        ],
      );
    });
  }
}
