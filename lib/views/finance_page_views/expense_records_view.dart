import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../global/common/AppColours.dart';
import '../../view_models/finance_view_model.dart';

class ExpenseRecordsView {
  static Future<void> expenseRecordsPopup(
      BuildContext context, ExpenseRecordsView expenseRecordsView) async {
    User? user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Calculates if the theme is light/dark mode
          final brightness = Theme.of(context).brightness;

          //Checks screen size to see if it is mobile or desktop
          double screenWidth = MediaQuery.of(context).size.width;
          bool isMobile = screenWidth < 600;
          return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Expense Records'),
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
                                  child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('expenseRecords')
                                          .where('groupId', isEqualTo: groupId)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (groupId == null) {
                                          return const SizedBox.shrink();
                                        }

                                        if (snapshot.data == null) {
                                          return const Scaffold(
                                            body: Center(child: CircularProgressIndicator()),
                                          );
                                        }

                                        var records = snapshot.data?.docs;

                                        return records!.isNotEmpty ? ListView.separated(
                                            padding: const EdgeInsets.all(15),
                                            shrinkWrap: true,
                                            separatorBuilder: (context, index) {
                                              return const SizedBox(height: 15);
                                            },
                                            itemCount: records!.length,
                                            itemBuilder: (context, index) {
                                              var record = records[index];
                                              return Container(
                                                  decoration: BoxDecoration(
                                                      color: AppColours.colour1(brightness),
                                                      borderRadius: BorderRadius.circular(20)),
                                                  child: InkWell(
                                                      //Desktop
                                                      child: !isMobile
                                                          ? ExpansionTile(
                                                              title: record['name'] != null
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(record['name'],
                                                                            style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                                color: AppColours
                                                                                    .colour4(
                                                                                        brightness),
                                                                                fontSize: isMobile
                                                                                    ? 16
                                                                                    : 24)),
                                                                        Column(
                                                                          children: [
                                                                            Text(
                                                                              "Expense Creator:",
                                                                              style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                                fontSize: isMobile
                                                                                    ? 10
                                                                                    : 24,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Align(
                                                                                alignment: Alignment
                                                                                    .centerRight,
                                                                                child: Chip(
                                                                                  avatar: const Icon(
                                                                                      Icons
                                                                                          .account_box),
                                                                                  label: FutureBuilder<
                                                                                          String?>(
                                                                                      future: viewModel
                                                                                          .returnExpenseRecordCreatorName(
                                                                                              record
                                                                                                  .id),
                                                                                      builder: (BuildContext
                                                                                              context,
                                                                                          AsyncSnapshot<
                                                                                                  String?>
                                                                                              snapshot) {
                                                                                        if ("${snapshot.data}" ==
                                                                                            "null") {
                                                                                          return const Text(
                                                                                              ""); //Due to a delay in the username loading
                                                                                        } else {
                                                                                          return Expanded(
                                                                                            child: Text(
                                                                                                "${snapshot.data}",
                                                                                                style: TextStyle(
                                                                                                    fontSize: isMobile ? 14 : 18,
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                    color: Colors.green)),
                                                                                          );
                                                                                        }
                                                                                      }),
                                                                                  backgroundColor: brightness ==
                                                                                          Brightness
                                                                                              .light
                                                                                      ? Colors.lightBlue[
                                                                                          100]
                                                                                      : Colors.blue[
                                                                                          900],
                                                                                  padding:
                                                                                      const EdgeInsets
                                                                                          .symmetric(
                                                                                          horizontal:
                                                                                              8,
                                                                                          vertical:
                                                                                              4),
                                                                                  shape:
                                                                                      RoundedRectangleBorder(
                                                                                    borderRadius:
                                                                                        BorderRadius
                                                                                            .circular(
                                                                                                20),
                                                                                    side: BorderSide(
                                                                                        color: Colors
                                                                                            .grey
                                                                                            .shade300),
                                                                                  ),
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : const Text(""),
                                                              children: [
                                                                //... Allows the users to be displayed on new line
                                                                ...record['assignedUsersRecords']
                                                                    .map((member) {
                                                                  return InkWell(
                                                                      child: ListTile(
                                                                          leading: Chip(
                                                                            avatar: const Icon(
                                                                                Icons.account_box),
                                                                            label: Text(
                                                                                member['userName'],
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  fontWeight:
                                                                                      FontWeight
                                                                                          .bold,
                                                                                  color: AppColours
                                                                                      .colour4(
                                                                                          brightness),
                                                                                )),
                                                                            backgroundColor:
                                                                                brightness ==
                                                                                        Brightness
                                                                                            .light
                                                                                    ? Colors.lightBlue[
                                                                                        100]
                                                                                    : Colors
                                                                                        .blue[900],
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .symmetric(
                                                                                    horizontal: 8,
                                                                                    vertical: 4),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(20),
                                                                              side: BorderSide(
                                                                                  color: Colors.grey
                                                                                      .shade300),
                                                                            ),
                                                                          ),
                                                                          trailing:
                                                                              member['paidOff'] ==
                                                                                      true
                                                                                  ? Text(
                                                                                      "Paid Off",
                                                                                      style: TextStyle(
                                                                                          color: Colors
                                                                                              .blue,
                                                                                          fontSize:
                                                                                              isMobile
                                                                                                  ? 12
                                                                                                  : 22,
                                                                                          fontWeight:
                                                                                              FontWeight
                                                                                                  .bold),
                                                                                    )
                                                                                  : const Text("")),
                                                                      onTap: () {
                                                                        expenseRecordsView
                                                                            .userExpenseRecordsHistoryPopup(
                                                                                context,
                                                                                record.id,
                                                                                member['userId']);
                                                                      });
                                                                }),
                                                              ],
                                                            )
                                                          //Mobile
                                                          : ExpansionTile(
                                                              title: record['name'] != null
                                                                  ? Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            const Text(
                                                                              "Creator:",
                                                                              style: TextStyle(
                                                                                  fontSize: 10,
                                                                                  fontWeight:
                                                                                      FontWeight
                                                                                          .bold),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 1,
                                                                            ),
                                                                            const Icon(
                                                                              Icons.account_box,
                                                                              size: 12,
                                                                            ),
                                                                            FutureBuilder<String?>(
                                                                                future: viewModel
                                                                                    .returnExpenseRecordCreatorName(
                                                                                        record.id),
                                                                                builder: (BuildContext
                                                                                        context,
                                                                                    AsyncSnapshot<
                                                                                            String?>
                                                                                        snapshot) {
                                                                                  if ("${snapshot.data}" ==
                                                                                      "null") {
                                                                                    return const Text(
                                                                                        ""); //Due to a delay in the username loading
                                                                                  } else {
                                                                                    return Expanded(
                                                                                      child: Text(
                                                                                          "${snapshot.data}",
                                                                                          style: TextStyle(
                                                                                              fontSize: isMobile
                                                                                                  ? 12
                                                                                                  : 18,
                                                                                              fontWeight: FontWeight
                                                                                                  .bold,
                                                                                              color:
                                                                                                  Colors.green)),
                                                                                    );
                                                                                  }
                                                                                }),
                                                                          ],
                                                                        ),
                                                                        Text(record['name'],
                                                                            style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                                color: AppColours
                                                                                    .colour4(
                                                                                        brightness),
                                                                                fontSize: isMobile
                                                                                    ? 16
                                                                                    : 24)),
                                                                      ],
                                                                    )
                                                                  : const Text(""),
                                                              children: [
                                                                //... Allows the users to be displayed on new line
                                                                ...record['assignedUsersRecords']
                                                                    .map((member) {
                                                                  return InkWell(
                                                                      child: ListTile(
                                                                          leading: Chip(
                                                                            avatar: const Icon(
                                                                                Icons.account_box),
                                                                            label: Text(
                                                                                member['userName'],
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  fontWeight:
                                                                                      FontWeight
                                                                                          .bold,
                                                                                  color: AppColours
                                                                                      .colour4(
                                                                                          brightness),
                                                                                )),
                                                                            backgroundColor:
                                                                                brightness ==
                                                                                        Brightness
                                                                                            .light
                                                                                    ? Colors.lightBlue[
                                                                                        100]
                                                                                    : Colors
                                                                                        .blue[900],
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .symmetric(
                                                                                    horizontal: 8,
                                                                                    vertical: 4),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius:
                                                                                  BorderRadius
                                                                                      .circular(20),
                                                                              side: BorderSide(
                                                                                  color: Colors.grey
                                                                                      .shade300),
                                                                            ),
                                                                          ),
                                                                          trailing:
                                                                              member['paidOff'] ==
                                                                                      true
                                                                                  ? Text(
                                                                                      "Paid Off",
                                                                                      style: TextStyle(
                                                                                          color: Colors
                                                                                              .blue,
                                                                                          fontSize:
                                                                                              isMobile
                                                                                                  ? 12
                                                                                                  : 22,
                                                                                          fontWeight:
                                                                                              FontWeight
                                                                                                  .bold),
                                                                                    )
                                                                                  : const Text("")),
                                                                      onTap: () {
                                                                        expenseRecordsView
                                                                            .userExpenseRecordsHistoryPopup(
                                                                                context,
                                                                                record.id,
                                                                                member['userId']);
                                                                      });
                                                                }),
                                                              ],
                                                            )));
                                            }) : const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.attach_money, size: 60, color: Colors.grey),
                                              SizedBox(height: 16),
                                              Text(
                                                "No expenses have been created.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Tap the + button to add an expense.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        );
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
  }

  //Change this method to work above
  Future<void> userExpenseRecordsHistoryPopup(
      BuildContext context, String recordId, String userId) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Calculates if the theme is light/dark mode
          final brightness = Theme.of(context).brightness;
          //Checks screen size to see if it is mobile or desktop
          double screenWidth = MediaQuery.of(context).size.width;
          bool isMobile = screenWidth < 600;
          return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Expense Payment History'),
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
                                  child: FutureBuilder(
                                      future:
                                          viewModel.returnExpenseRecordPayments(recordId, userId),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<dynamic>> snapshot) {
                                        if ("${snapshot.data}" == "null") {
                                          return const Text("");
                                        } else {
                                          return ListView.separated(
                                              padding: const EdgeInsets.all(15),
                                              shrinkWrap: true,
                                              separatorBuilder: (context, index) {
                                                return const SizedBox(height: 15);
                                              },
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (context, index) {
                                                final payment = snapshot.data?[index];
                                                return GestureDetector(
                                                    key: UniqueKey(),
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color: AppColours.colour1(brightness),
                                                            borderRadius:
                                                                BorderRadius.circular(20)),
                                                        child: ListTile(
                                                          title: Text(
                                                            "£${payment['amountPaid']}",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.green,
                                                                fontSize: isMobile ? 14 : 24),
                                                          ),
                                                          trailing: Text(
                                                            DateFormat('MMM d, h:mm a').format(
                                                                payment['datePaid'].toDate()),
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: isMobile ? 12 : 22),
                                                          ),
                                                        )));
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
  }
}
