import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/views/finance_page_views/bottom_sheets/add_expense_bottom_sheet_view.dart';

import '../../view_models/finance_view_model.dart';

class ExpenseRecordsView {
  static Future<void> expenseRecordsPopup(BuildContext context, ExpenseRecordsView expenseRecordsView) async {
    User? user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Checks screen size to see if it is mobile or desktop
          double screenWidth = MediaQuery.of(context).size.width;
          bool isMobile = screenWidth < 600;
          return Consumer<FinanceViewModel>(
              builder: (context, viewModel, child) {
                return AlertDialog(
                  scrollable: true,
                  title: Text('Expense Records'),
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
                                          color: viewModel.colour2,
                                          borderRadius: const BorderRadius
                                              .vertical(
                                              top: Radius.circular(30),
                                              bottom: Radius.circular(30))),


                                      child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('expenseRecords')
                                              .where('groupId', isEqualTo: groupId)
                                              .snapshots(),
                                          builder: (context, snapshot) {

                                            if (snapshot.data == null) {
                                              return Scaffold(
                                                body: Center(child: CircularProgressIndicator()),
                                              );
                                            }

                                            var records = snapshot.data?.docs;

                                            return ListView.separated(
                                                padding: EdgeInsets.all(15),
                                                shrinkWrap: true,
                                                separatorBuilder: (context,
                                                    index) {
                                                  return SizedBox(height: 15);
                                                },
                                                itemCount: records!.length,
                                                itemBuilder: (context, index) {
                                                  var record = records[index];
                                                  return Container(
                                                      decoration: BoxDecoration(
                                                          color: viewModel.colour1,
                                                          borderRadius: BorderRadius.circular(20)),
                                                      child: InkWell(
                                                        child: ExpansionTile(
                                                            title: record['name'] != null
                                                            ? Text(record['name'],
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        color: viewModel.colour4,
                                                                        fontSize: isMobile? 16 : 24))
                                                          : Text(""),
                                                          children: [
                                                            //... Allows the users to be displayed on new line
                                                            ...record['assignedUsersRecords'].map((member) {
                                                              return InkWell(
                                                                child: ListTile(
                                                                  leading: Chip(
                                                                    avatar: Icon(Icons.account_box),
                                                                    label: Text(
                                                                        member['userName'],
                                                                        style: TextStyle(
                                                                          fontSize: 16,
                                                                          fontWeight: FontWeight.bold,
                                                                          color: viewModel.colour4,)
                                                                    ),
                                                                    backgroundColor: Colors.lightBlue[100],
                                                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      side: BorderSide(color: Colors.grey.shade300),
                                                                    ),
                                                                  ),
                                                                  trailing: member['paidOff'] == true
                                                                  ? Text("Paid Off",
                                                                    style: TextStyle(
                                                                        color: Colors.blue,
                                                                        fontSize: isMobile ? 12 : 22,
                                                                        fontWeight: FontWeight.bold
                                                                    ),
                                                                  )
                                                                      : const Text("")
                                                                ),
                                                                onTap: () {
                                                                  expenseRecordsView.userExpenseRecordsHistoryPopup(context, record.id, member['userId']);
                                                                }
                                                              );
                                                            }),
                                                          ],
                                                        ),
                                                      ));
                                                });
                                          }
                                      )
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

  //Change this method to work above
  Future<void> userExpenseRecordsHistoryPopup(BuildContext context, String recordId, String userId) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Checks screen size to see if it is mobile or desktop
          double screenWidth = MediaQuery.of(context).size.width;
          bool isMobile = screenWidth < 600;
          return Consumer<FinanceViewModel>(
              builder: (context, viewModel, child) {
                return AlertDialog(
                  scrollable: true,
                  title: Text('Expense Payment History'),
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
                                          color: viewModel.colour2,
                                          borderRadius: const BorderRadius
                                              .vertical(
                                              top: Radius.circular(30),
                                              bottom: Radius.circular(30))),


                                      child: FutureBuilder(
                                          future: viewModel.returnExpenseRecordPayments(recordId, userId),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<List<dynamic>>
                                              snapshot) {
                                            if ("${snapshot.data}" == "null") {
                                              return const Text("");
                                            } else {
                                              return ListView.separated(
                                                  padding: EdgeInsets.all(15),
                                                  shrinkWrap: true,
                                                  separatorBuilder: (context, index) {
                                                    return SizedBox(height: 15);
                                                  },
                                                  itemCount: snapshot.data!.length,
                                                  itemBuilder: (context, index) {
                                                    final payment = snapshot.data?[index];
                                                    return GestureDetector(
                                                    key: UniqueKey(),
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color: viewModel.colour1,
                                                            borderRadius: BorderRadius.circular(20)),
                                                        child: ListTile(
                                                          title: Text("£${payment['amountPaid']}",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.green,
                                                                fontSize: isMobile ? 14 : 24
                                                            ),
                                                          ),
                                                          trailing: Text(DateFormat('MMM d, h:mm a').format(payment['datePaid'].toDate()),
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                                fontSize: isMobile ? 12 : 22
                                                            ),
                                                          ),
                                                        )));
                                              });
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
  }
}