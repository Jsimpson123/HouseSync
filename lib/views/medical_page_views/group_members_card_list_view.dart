import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/models/shopping_model.dart';
import 'package:shared_accommodation_management_app/models/user_model.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/medical_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';

class GroupMembersCardListView extends StatefulWidget {
  const GroupMembersCardListView({super.key});

  @override
  State<GroupMembersCardListView> createState() {
    return _GroupMembersCardListView();
  }
}

class _GroupMembersCardListView extends State<GroupMembersCardListView> {
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      padding: EdgeInsets.all(20),
      child: ListView.separated(
      padding: EdgeInsets.all(15),
      separatorBuilder: (context, index) {
      return SizedBox(height: 15);
      },
      scrollDirection: Axis.vertical,
      physics: ScrollPhysics(),
      shrinkWrap: true,
      itemCount: viewModel.members.length,
      itemBuilder: (context, index) {
      // final member = viewModel.houseSyncUsers[index];
      return GestureDetector(
      key: UniqueKey(),
      child: Container(
      decoration: BoxDecoration(
      color: viewModel.colour1,
      borderRadius: BorderRadius.circular(20)),
      child: ListTile(
      title: Text(
      viewModel.members[index],
      style: TextStyle(
      color: viewModel.colour4,
      fontSize: 16)),

        // onTap: () => viewSpecificUsersMedicalConditionsPopup(context, viewModel.houseSyncUsers[index]),
      )));
      }),
      ),
      ),
      ],
      );
    });
  }

  Future<void> viewSpecificUsersMedicalConditionsPopup(BuildContext context, HouseSyncUser houseSyncUser) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<MedicalViewModel>(builder: (context, viewModel, child) {
            Future medicalNamesFuture = viewModel.returnMedicalConditionsNamesList(houseSyncUser.userId);
            return StatefulBuilder(builder: (context, setStates) {
              return AlertDialog(
                scrollable: true,
                title: Text('Medical Conditions'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        child: Column(
                          children: <Widget> [
                            Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: viewModel.colour2,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(30),
                                            bottom: Radius.circular(30))),

                                    child: FutureBuilder(
                                        future: Future.wait([medicalNamesFuture]),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<dynamic>> snapshot) {
                                          if ("${snapshot.data}" == "null") {
                                            return const Text(
                                                "");
                                          } else {
                                            return Expanded(
                                              child: ListView.separated(
                                                  padding: EdgeInsets.all(15),
                                                  shrinkWrap: true,
                                                  separatorBuilder: (context, index) {
                                                    return SizedBox(height: 15);
                                                  },
                                                  itemCount: snapshot.data?[0]!.length,
                                                  itemBuilder: (context, index) {
                                                    return Container(
                                                        decoration: BoxDecoration(
                                                            color: viewModel.colour1,
                                                            borderRadius:
                                                            BorderRadius.circular(
                                                                20)),
                                                        child: ListTile(
                                                          title: Text(
                                                              snapshot.data?[0]![index],
                                                              style: TextStyle(
                                                                  color:
                                                                  viewModel.colour4,
                                                                  fontSize: 16)),
                                                        ));
                                                  }),
                                            );
                                          }
                                        })
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
        });
  }
}