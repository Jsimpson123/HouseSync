import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../../global/common/AppColours.dart';

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
    final brightness = Theme.of(context).brightness;
    return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: AppColours.colour2(brightness),
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30))),
              padding: const EdgeInsets.all(20),
              child: ListView.separated(
                  padding: const EdgeInsets.all(15),
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 15);
                  },
                  scrollDirection: Axis.vertical,
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: viewModel.memberIds.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        key: UniqueKey(),
                        child: Container(
                            decoration: BoxDecoration(
                                color: AppColours.colour1(brightness),
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              title: Row(
                                children: [
                                  const Icon(Icons.account_box),
                                  Text(viewModel.members[index],
                                      style: TextStyle(
                                          color: AppColours.colour4(brightness),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                ],
                              ),
                            )));
                  }),
            ),
          ),
        ],
      );
    });
  }
}