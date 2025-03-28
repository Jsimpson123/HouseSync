import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/finance_view_model.dart';

class ExpenseRecordsView {
  static void expenseRecordsPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Checks screen size to see if it is mobile or desktop
          double screenWidth = MediaQuery
              .of(context)
              .size
              .width;
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
                                          stream: FirebaseFirestore.instance.collection('expenseRecords').snapshots(),
                                          builder: (context, snapshot) {

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
                                                            title: Text(record['name'],
                                                                style: TextStyle(
                                                                    color: viewModel.colour4,
                                                                    fontSize: 16)),
                                                          children: [
                                                            //... Allows the users to be displayed on new line
                                                            ...record['assignedUsersRecords'].map((user) {
                                                              return InkWell(
                                                                child: ListTile(
                                                                  leading: Icon(Icons.account_box),
                                                                  title: Text(user['userName']),
                                                                ),
                                                                //onTap: () => ExpenseRecordsView().userExpenseRecordsHistoryPopup(context, record)
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
  // Future<void> userExpenseRecordsHistoryPopup(BuildContext context, var record) async {
  //   //Checks screen size to see if it is mobile or desktop
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   bool isMobile = screenWidth < 600;
  //
  //   User? user = FirebaseAuth.instance.currentUser;
  //
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
  //           Future usernamesFuture = viewModel.returnAssignedExpenseUsernamesList(expenseId);
  //           Future amountsFuture = viewModel.returnAssignedUsersAmountOwedList(expenseId);
  //           Future userIdsFuture = viewModel.returnAssignedExpenseUserIdsList(expenseId);
  //           return StatefulBuilder(builder: (context, setStates) {
  //             return AlertDialog(
  //               scrollable: true,
  //               title: Text('Expense Details'),
  //               content: SingleChildScrollView(
  //                 child: SizedBox(
  //                   width: double.maxFinite,
  //                   height: isMobile ? 600 : 400,
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Form(
  //                       child: Column(
  //                         children: <Widget>[
  //                           Expanded(
  //                               child: Container(
  //                                   decoration: BoxDecoration(
  //                                       color: viewModel.colour2,
  //                                       borderRadius: BorderRadius.vertical(
  //                                           top: Radius.circular(30),
  //                                           bottom: Radius.circular(30))),
  //
  //                                   child: FutureBuilder(
  //                                       future: Future.wait([usernamesFuture, amountsFuture, userIdsFuture]),
  //                                       builder: (BuildContext context,
  //                                           AsyncSnapshot<List<dynamic>> snapshot) {
  //                                         if ("${snapshot.data}" == "null") {
  //                                           return const Text(
  //                                               ""); //Due to a delay in the username loading
  //                                         } else {
  //                                           return ListView.separated(
  //                                               padding: EdgeInsets.all(15),
  //                                               shrinkWrap: true,
  //                                               separatorBuilder: (context, index) {
  //                                                 return SizedBox(height: 15);
  //                                               },
  //                                               itemCount: snapshot.data?[0]!.length,
  //                                               itemBuilder: (context, index) {
  //                                                 TextEditingController enteredUserAmountController = TextEditingController();
  //                                                 // double amountOwed = double.parse(snapshot.data?[1]![index]);
  //                                                 return Container(
  //                                                     decoration: BoxDecoration(
  //                                                         color: viewModel.colour1,
  //                                                         borderRadius:
  //                                                         BorderRadius.circular(
  //                                                             20)),
  //                                                     child: ListTile(
  //                                                         leading: Text(
  //                                                             "£" + snapshot.data?[1]![index],
  //                                                             style: TextStyle(
  //                                                                 color: Colors.green,
  //                                                                 fontWeight: FontWeight.bold,
  //                                                                 fontSize: 16)),
  //                                                         title: Text(
  //                                                             snapshot.data?[0]![index],
  //                                                             style: TextStyle(
  //                                                                 color:
  //                                                                 viewModel.colour4,
  //                                                                 fontSize: 16)),
  //
  //                                                         //TextField only shows if the current user owes money
  //                                                         subtitle: user?.uid == snapshot.data?[2][index]
  //                                                             ? TextField(
  //                                                           decoration: const InputDecoration(
  //                                                               hintText: "Amount Owed",
  //                                                               border: OutlineInputBorder()),
  //                                                           controller: enteredUserAmountController,
  //                                                         ) : null,
  //
  //                                                         //Add Icon only shows if the current user owes money
  //                                                         trailing: user?.uid == snapshot.data?[2][index]
  //                                                             ? IconButton(
  //                                                             onPressed: () {
  //                                                               setState(() async {
  //                                                                 if (enteredUserAmountController.text.isNotEmpty) {
  //                                                                   await viewModel.updateUserAmountPaid(
  //                                                                       expenseId,
  //                                                                       user!.uid,
  //                                                                       num.parse(enteredUserAmountController.text)
  //                                                                   );
  //                                                                 }
  //                                                               });
  //
  //                                                             }, icon: Icon(Icons.add))
  //                                                             : null
  //                                                     ));
  //                                               });
  //                                         }
  //                                       })
  //                               )
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           });
  //         });
  //       });
  // }
}