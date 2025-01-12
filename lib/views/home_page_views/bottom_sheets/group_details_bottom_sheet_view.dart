import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/user_model.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';

import '../../../pages/create_or_join_group_page.dart';

class GroupDetailsBottomSheetView extends StatelessWidget{
  const GroupDetailsBottomSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Consumer<GroupViewModel>(builder: (context, viewModel, child){
      return Container(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            //Group name
            FutureBuilder<String?>(
                future: viewModel.returnGroupName(user!.uid),
                builder: (BuildContext context,
                    AsyncSnapshot<String?> snapshot) {
                  if ("${snapshot.data}" == "null") {
                    return const Text(
                        ""); //Due to a delay in the data loading
                  } else {
                    return Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.center,
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

            Divider(),

            //Group members
            FutureBuilder<String?>(
                future: viewModel.returnGroupMembers(user!.uid),
                builder: (BuildContext context,
                    AsyncSnapshot<String?> snapshot) {
                  if ("${snapshot.data}" == "null") {
                    return const Text(
                        ""); //Due to a delay in the data loading
                  } else {
                    return Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text("Group Members: ${snapshot.data}",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: viewModel.colour4)),
                        ),
                      ),
                    );
                  }
                }),

            SizedBox(width: 15),

            //Leave group button
            ElevatedButton(
                onPressed: () {
                  viewModel.leaveGroup(user!.uid);

                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => CreateOrJoinGroupPage()));
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: viewModel.colour1,
                    backgroundColor: viewModel.colour3,
                    textStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                child: const Text("Leave Group")),
          ],
        ),
      );
    });
  }
}