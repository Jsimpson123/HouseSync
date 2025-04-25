import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';
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
                              onTap: () =>
                                  viewSpecificUsersMedicalConditionsPopup(
                                      context, viewModel.memberIds[index]),
                            )));
                  }),
            ),
          ),
        ],
      );
    });
  }

  Future<void> viewSpecificUsersMedicalConditionsPopup(
      BuildContext context, String memberId) async {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<MedicalViewModel>(
              builder: (context, viewModel, child) {
            Future medicalNamesFuture = viewModel.returnMedicalConditionsNamesList(memberId);
            Future medicalDescsFuture = viewModel.returnMedicalConditionsDescsList(memberId);
            Future medicalIds = viewModel.returnMedicalConditionIds(memberId);

            return StatefulBuilder(builder: (context, setStates) {
              return AlertDialog(
                scrollable: true,
                title: Text('Medical Conditions'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: viewModel.colour2,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(30),
                                            bottom: Radius.circular(30))),
                                    child: FutureBuilder(
                                        future: Future.wait([
                                          medicalNamesFuture,
                                          medicalDescsFuture,
                                          medicalIds
                                        ]),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<dynamic>>
                                                snapshot) {
                                          if ("${snapshot.data}" == "null") {
                                            return const Text("");
                                          } else {
                                            return GridView.builder(
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: isMobile ? 1 : 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                  childAspectRatio: isMobile ? 0.8 : 1.4,
                                                ),
                                                padding: EdgeInsets.all(15),
                                                shrinkWrap: true,
                                                itemCount: snapshot.data?[0]!.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                      decoration: BoxDecoration(
                                                          color: viewModel.colour1,
                                                          borderRadius: BorderRadius.circular(20)),
                                                      child: Card(
                                                        color: Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10)),
                                                        child: Column(
                                                          children: [
                                                            Stack(
                                                              children: [
                                                                // Icon pinned to the left
                                                                Positioned(
                                                                  left: 0,
                                                                  top: 0,
                                                                  child: Icon(
                                                                    Icons.medical_information_outlined,
                                                                    size: isMobile ? 20 : 30,
                                                                  ),
                                                                ),

                                                                //Centring text
                                                                Align(
                                                                  alignment: Alignment.center,
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.max,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      //Makes text seem centred
                                                                      SizedBox(width: isMobile ? 30 : 40),
                                                                      Flexible(
                                                                        child: Text(
                                                                          snapshot.data?[0]![index] ?? '',
                                                                          textAlign: TextAlign.center,
                                                                          softWrap: true,
                                                                          style: TextStyle(
                                                                            color: viewModel.colour4,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: isMobile ? 20 : 24,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      //For symmetry
                                                                      SizedBox(width: isMobile ? 30 : 40),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            //Separating line
                                                            Container(
                                                              decoration: const BoxDecoration(
                                                                border: Border(
                                                                  bottom: BorderSide(color: Colors.black),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 30),
                                                            Expanded(
                                                              child: SingleChildScrollView(
                                                                child: Padding(
                                                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                  child: Center(
                                                                    child: Text(
                                                                        snapshot.data?[1]![index],
                                                                        style: TextStyle(
                                                                            color: viewModel.colour4,
                                                                            fontSize: isMobile ? 14 : 16)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                                              child: user?.uid == memberId
                                                                  ? ElevatedButton(
                                                                  onPressed: () async {
                                                                    await viewModel.deleteMedicalCondition(snapshot.data?[2][index]);
                                                                    showToast(message: "Condition Successfully Deleted");
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                      foregroundColor: viewModel.colour1,
                                                                      backgroundColor: Colors.red,
                                                                      textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(20))),
                                                                  child: const Text("Delete"))
                                                           : null
                                                            )
                                                          ],
                                                        ),
                                                      ));
                                                });
                                          }
                                        }))),
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
