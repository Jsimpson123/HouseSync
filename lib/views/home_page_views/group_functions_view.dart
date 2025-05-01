import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/bottom_sheets/create_group_bottom_sheet_view.dart';

import 'bottom_sheets/join_group_bottom_sheet_view.dart';

class GroupFunctionsView extends StatelessWidget {
  const GroupFunctionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Consumer<GroupViewModel>(builder: (context, viewModel, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Row(
            children: [
              //Create group
              Expanded(
                key: const Key("createGroupButton"),
                flex: 1,
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            child: Text(
                              "Create Group",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  onTap: () {
                    viewModel.displayBottomSheet(const CreateGroupBottomSheetView(), context);
                  },
                ),
              ),

              const SizedBox(width: 20),

              //Join group
              Expanded(
                flex: 1,
                child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(children: [
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.center,
                            child: FittedBox(
                              child: Text(
                                "Join Group",
                                key: const Key("joinGroupButton"),
                                style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    onTap: () {
                      viewModel.displayBottomSheet(const JoinGroupBottomSheetView(), context);
                    }),
              ),
            ],
          ),
        );
      }),
    );
  }
}
