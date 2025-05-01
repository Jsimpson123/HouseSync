import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/medical_view_model.dart';

import '../../global/common/AppColours.dart';

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
    final brightness = Theme.of(context).brightness;
    return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: AppColours.colour2(brightness),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
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
                              onTap: () => viewSpecificUsersMedicalConditionsPopup(
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
    final brightness = Theme.of(context).brightness;

    TextEditingController enteredContactName = TextEditingController();
    TextEditingController enteredContactNumber = TextEditingController();

    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<MedicalViewModel>(builder: (context, viewModel, child) {
            Future medicalNamesFuture = viewModel.returnMedicalConditionsNamesList(memberId);
            Future medicalDescsFuture = viewModel.returnMedicalConditionsDescsList(memberId);
            Future medicalIds = viewModel.returnMedicalConditionIds(memberId);

            return StatefulBuilder(builder: (context, setStates) {
              return AlertDialog(
                scrollable: true,
                title: SizedBox(
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Medical Conditions",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                      Column(
                        children: [
                          const Text(
                            "Emergency Contact:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.warning),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FutureBuilder<String?>(
                                future: viewModel.returnUserEmergencyContactName(memberId),
                                builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                  if ("${snapshot.data}" == "null") {
                                    return const Text(
                                        ""); //Due to a delay in the group code loading
                                  } else {
                                    return Expanded(
                                      // flex: 1,
                                      child: Text("${snapshot.data}",
                                          style: TextStyle(
                                              fontSize: isMobile ? 14 : 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red)),
                                    );
                                  }
                                }),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FutureBuilder<String?>(
                                future: viewModel.returnUserEmergencyContactNumber(memberId),
                                builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                  if ("${snapshot.data}" == "null") {
                                    return const Text(
                                        ""); //Due to a delay in the group code loading
                                  } else {
                                    return Expanded(
                                      child: Text("${snapshot.data}",
                                          style: TextStyle(
                                              fontSize: isMobile ? 14 : 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red)),
                                    );
                                  }
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                                        color: AppColours.colour2(brightness),
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(30), bottom: Radius.circular(30))),
                                    child: FutureBuilder(
                                        future: Future.wait(
                                            [medicalNamesFuture, medicalDescsFuture, medicalIds]),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<dynamic>> snapshot) {
                                          if ("${snapshot.data}" == "null") {
                                            return const Text("");
                                          } else {
                                            return GridView.builder(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: isMobile ? 1 : 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                  childAspectRatio: isMobile ? 0.8 : 1.4,
                                                ),
                                                padding: const EdgeInsets.all(15),
                                                shrinkWrap: true,
                                                itemCount: snapshot.data?[0]!.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                      decoration: BoxDecoration(
                                                          color: AppColours.colour1(brightness),
                                                          borderRadius: BorderRadius.circular(20)),
                                                      child: Card(
                                                        color: brightness == Brightness.light
                                                            ? Colors.white
                                                            : AppColours.colour1(brightness),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(10)),
                                                        child: Column(
                                                          children: [
                                                            Stack(
                                                              children: [
                                                                // Icon pinned to the left
                                                                Positioned(
                                                                  left: 0,
                                                                  top: 0,
                                                                  child: Icon(
                                                                    Icons
                                                                        .medical_information_outlined,
                                                                    size: isMobile ? 20 : 30,
                                                                  ),
                                                                ),

                                                                //Centring text
                                                                Align(
                                                                  alignment: Alignment.center,
                                                                  child: Row(
                                                                    mainAxisSize: MainAxisSize.max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment.center,
                                                                    children: [
                                                                      //Makes text seem centred
                                                                      SizedBox(
                                                                          width:
                                                                              isMobile ? 30 : 40),
                                                                      Flexible(
                                                                        child: Text(
                                                                          snapshot.data?[0]![
                                                                                  index] ??
                                                                              '',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          softWrap: true,
                                                                          style: TextStyle(
                                                                            color:
                                                                                AppColours.colour4(
                                                                                    brightness),
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                isMobile ? 20 : 24,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      //For symmetry
                                                                      SizedBox(
                                                                          width:
                                                                              isMobile ? 30 : 40),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),

                                                            //Separating line
                                                            Container(
                                                              decoration: const BoxDecoration(
                                                                border: Border(
                                                                  bottom: BorderSide(
                                                                      color: Colors.black),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 30),
                                                            Expanded(
                                                              child: SingleChildScrollView(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.fromLTRB(
                                                                          10, 0, 10, 0),
                                                                  child: Center(
                                                                    child: Text(
                                                                        snapshot.data?[1]![index],
                                                                        style: TextStyle(
                                                                            color:
                                                                                AppColours.colour4(
                                                                                    brightness),
                                                                            fontSize: isMobile
                                                                                ? 14
                                                                                : 16)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                                padding: const EdgeInsets.fromLTRB(
                                                                    0, 0, 0, 5),
                                                                child: user?.uid == memberId
                                                                    ? ElevatedButton(
                                                                        onPressed: () async {
                                                                          await viewModel
                                                                              .deleteMedicalCondition(
                                                                                  snapshot.data?[2]
                                                                                      [index]);
                                                                          showToast(
                                                                              message:
                                                                                  "Condition Successfully Deleted");
                                                                        },
                                                                        style: ElevatedButton.styleFrom(
                                                                            foregroundColor:
                                                                                AppColours.colour1(
                                                                                    brightness),
                                                                            backgroundColor:
                                                                                Colors.red,
                                                                            textStyle: const TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.w700,
                                                                                fontSize: 16),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                    BorderRadius
                                                                                        .circular(
                                                                                            20))),
                                                                        child: const Text("Delete"))
                                                                    : null)
                                                          ],
                                                        ),
                                                      ));
                                                });
                                          }
                                        }))),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                                child: user?.uid == memberId
                                    ? ElevatedButton(
                                        onPressed: () async {
                                          viewModel.displayBottomSheet(
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context).viewInsets.bottom),
                                                  //Ensures the keyboard doesn't cover the textfields
                                                  child: Container(
                                                      height: 260,
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text("Emergency Contact Details",
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: AppColours.colour3(
                                                                      brightness))),
                                                          const SizedBox(height: 15),
                                                          TextField(
                                                            key: const Key(
                                                                "emergencyContactNameTextField"),
                                                            decoration: const InputDecoration(
                                                                hintText: "Emergency Contact Name",
                                                                border: OutlineInputBorder()),
                                                            controller: enteredContactName,
                                                          ),
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                          TextField(
                                                            key: const Key(
                                                                "emergencyContactNumberTextField"),
                                                            decoration: const InputDecoration(
                                                                hintText:
                                                                    "Emergency Contact Phone Number",
                                                                border: OutlineInputBorder()),
                                                            controller: enteredContactNumber,
                                                            keyboardType: TextInputType.phone,
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter.allow(
                                                                  RegExp(r'[0-9+ ]')),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 15),
                                                          ElevatedButton(
                                                              key: const Key(
                                                                  "submitNewEventDetailsButton"),
                                                              style: ElevatedButton.styleFrom(
                                                                  foregroundColor:
                                                                      AppColours.colour1(
                                                                          brightness),
                                                                  backgroundColor:
                                                                      AppColours.colour3(
                                                                          brightness),
                                                                  fixedSize: const Size(100, 50)),
                                                              onPressed: () async {
                                                                if (enteredContactName
                                                                        .text.isNotEmpty &&
                                                                    enteredContactNumber
                                                                        .text.isNotEmpty) {
                                                                  Map<String, dynamic>
                                                                      emergencyContact = ({
                                                                    'contactName':
                                                                        enteredContactName.text,
                                                                    'contactNumber':
                                                                        enteredContactNumber.text
                                                                  });
                                                                  await viewModel
                                                                      .addEmergencyContact(
                                                                          user!.uid,
                                                                          emergencyContact);

                                                                  setState(() {
                                                                    emergencyContact = ({
                                                                      'contactName':
                                                                          enteredContactName.text,
                                                                      'contactNumber':
                                                                          enteredContactNumber.text
                                                                    });
                                                                  });

                                                                  Navigator.of(context)
                                                                      .pop(); //Makes bottom medical bar disappear

                                                                  showToast(
                                                                      message:
                                                                          "Emergency contact added\nName: ${enteredContactName.text}\nNumber: ${enteredContactNumber.text}");
                                                                } else {
                                                                  showToast(
                                                                      message:
                                                                          "Please fill out all fields");
                                                                }
                                                              },
                                                              child: const Text("Submit"))
                                                        ],
                                                      ))),
                                              context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            foregroundColor: AppColours.colour1(brightness),
                                            backgroundColor: AppColours.colour4(brightness),
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.w700, fontSize: 16),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20))),
                                        child: const Text("Add Emergency Contact"))
                                    : null),
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
