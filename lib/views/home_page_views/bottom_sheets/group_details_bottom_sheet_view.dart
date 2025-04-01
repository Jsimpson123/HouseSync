import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/user_model.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';

import '../../../pages/create_or_join_group_page.dart';

class GroupDetailsBottomSheetView extends StatefulWidget {
  const GroupDetailsBottomSheetView({super.key});

  @override
  State<GroupDetailsBottomSheetView> createState() {
    return _GroupDetailsBottomSheetView();
  }
}

class _GroupDetailsBottomSheetView extends State<GroupDetailsBottomSheetView> {
  User? user = FirebaseAuth.instance.currentUser;

  GroupViewModel groupViewModel = GroupViewModel();

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: viewModel.colour2,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(30))),
              padding: EdgeInsets.all(20),
              child: ListView.separated(
                  padding: EdgeInsets.all(15),
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 15);
                  },
                  scrollDirection: Axis.vertical,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: viewModel.memberIds.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        key: UniqueKey(),
                        child: Container(
                            decoration: BoxDecoration(
                                color: viewModel.colour1,
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Icon(Icons.account_box),
                                  Text(viewModel.members[index],
                                      style: TextStyle(
                                          color: viewModel.colour4,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                ],
                              ),
                              // onTap: () =>
                              //     viewSpecificUsersMedicalConditionsPopup(
                              //         context, viewModel.memberIds[index]),
                            )));
                  }),
            ),
          ),
        ],
      );
    });
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   User? user = FirebaseAuth.instance.currentUser;
  //
  //   return Consumer<GroupViewModel>(builder: (context, viewModel, child){
  //     return Container(
  //       height: 150,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //
  //           //Group name
  //           FutureBuilder<String?>(
  //               future: viewModel.returnGroupName(user!.uid),
  //               builder: (BuildContext context,
  //                   AsyncSnapshot<String?> snapshot) {
  //                 if ("${snapshot.data}" == "null") {
  //                   return const Text(
  //                       ""); //Due to a delay in the data loading
  //                 } else {
  //                   return Expanded(
  //                     flex: 2,
  //                     child: Align(
  //                       alignment: Alignment.center,
  //                       child: FittedBox(
  //                         fit: BoxFit.fitHeight,
  //                         child: Text("${snapshot.data}",
  //                             style: TextStyle(
  //                                 fontSize: 42,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: viewModel.colour4)),
  //                       ),
  //                     ),
  //                   );
  //                 }
  //               }),
  //
  //           Divider(),
  //
  //           //Group members
  //           FutureBuilder<String?>(
  //               future: viewModel.returnGroupMembers(user!.uid),
  //               builder: (BuildContext context,
  //                   AsyncSnapshot<String?> snapshot) {
  //                 if ("${snapshot.data}" == "null") {
  //                   return const Text(
  //                       ""); //Due to a delay in the data loading
  //                 } else {
  //                   return Expanded(
  //                     flex: 2,
  //                     child: Align(
  //                       alignment: Alignment.center,
  //                       child: FittedBox(
  //                         fit: BoxFit.fitHeight,
  //                         child: Text("Group Members: ${snapshot.data}",
  //                             style: TextStyle(
  //                                 fontSize: 28,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: viewModel.colour4)),
  //                       ),
  //                     ),
  //                   );
  //                 }
  //               }),
  //
  //           SizedBox(width: 15),
  //
  //           //Leave group button
  //           ElevatedButton(
  //               onPressed: () {
  //                 viewModel.leaveGroup(user!.uid);
  //
  //                 Navigator.push(
  //                     context, MaterialPageRoute(builder: (context) => CreateOrJoinGroupPage()));
  //               },
  //               style: ElevatedButton.styleFrom(
  //                   foregroundColor: viewModel.colour1,
  //                   backgroundColor: viewModel.colour3,
  //                   textStyle:
  //                   const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(20))),
  //               child: const Text("Leave Group")),
  //         ],
  //       ),
  //     );
  //   });
  // }