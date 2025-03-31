import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';

import '../../pages/finance_page.dart';
import '../../view_models/finance_view_model.dart';

class ExpenseCardListView extends StatefulWidget {
  const ExpenseCardListView({super.key});

  @override
  State<ExpenseCardListView> createState() {
    return _ExpenseCardListView();
    
  }
}

class _ExpenseCardListView extends State<ExpenseCardListView> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: viewModel.colour2,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                  child: GridView.builder(
                      padding: EdgeInsets.all(15),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: isMobile ? 0.8 : 2.7,
                      ),
                    itemCount: viewModel.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = viewModel.expenses[index];
                        return InkWell(
                          onTap: () => expenseDetailsPopup(context, expense.expenseId),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: viewModel.colour1,
                                  borderRadius: BorderRadius.circular(20)),
                            child: Card(
                              color: Colors.white,
                              child:
                                  SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Icon(Icons.attach_money),
                                            Expanded(
                                                      child: Center(
                                                        child: Text(viewModel.getExpenseTitle(index),
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                                color: viewModel.colour4,
                                                                fontSize: 24,
                                                                fontWeight: FontWeight.bold)),
                                                      ),
                                            ),
                                          ],
                                        ),
                                        //Separating line
                                        // Container(
                                        //   decoration: BoxDecoration(
                                        //     border: Border(
                                        //       bottom: BorderSide(color: Colors.black),
                                        //     ),
                                        //   ),
                                        // ),
                                        SizedBox(height: 15),
                                        Center(
                                          child: FutureBuilder<num?>(
                                              future: viewModel.returnAssignedExpenseAmount(expense.expenseId),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<num?> snapshot) {
                                                if ("${snapshot.data}" == "null") {
                                                  return const Text(
                                                      ""); //Due to a delay in the amount loading
                                                } else if ("${snapshot.data}" == "0") {
                                                  //FIX THIS
                                                  setState(() async {
                                                    await viewModel.deleteExpense(expense.expenseId);
                                                              
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => FinancePage()));
                                                  });
                                                  return SizedBox();
                                                } else {
                                                  return FittedBox(
                                                      fit: BoxFit.fitHeight,
                                                      child: Text(
                                                          "£${snapshot.data}",
                                                          style: TextStyle(
                                                              fontSize: 24,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.red)),
                                                  );
                                                }
                                              }),
                                        ),
                                    
                                        SizedBox(height: 15),
                                        Center(
                                          child: FutureBuilder<String?>(
                                              future: viewModel.returnAssignedExpenseUsernames(expense.expenseId),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<String?> snapshot) {
                                                if ("${snapshot.data}" == "null") {
                                                  return const Text(
                                                      ""); //Due to a delay in the username loading
                                                } else {
                                                  return FittedBox(
                                                    fit: BoxFit.fitHeight,
                                                    child: Column(
                                                      children: [
                                                        Icon(Icons.supervisor_account_sharp,
                                                          size: 35),
                                                        Text(
                                                            "${snapshot.data}",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                                color: viewModel.colour4)),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              }),
                                        ),

                                        FutureBuilder(
                                          future: viewModel.returnExpenseCreatorId(expense.expenseId),
                                          builder: (BuildContext context,
                                          AsyncSnapshot<String?> snapshot) {
                                            if (user?.uid == snapshot.data) {
                                              return ElevatedButton(
                                                  onPressed: () {
                                                      viewModel.deleteExpenseUponClick(index);
                                                  },
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                      foregroundColor: viewModel
                                                          .colour1,
                                                      backgroundColor: Colors
                                                          .red,
                                                      textStyle:
                                                      TextStyle(
                                                          fontWeight: FontWeight
                                                              .w700,
                                                          fontSize: 16),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius
                                                              .circular(20))),
                                                  child: const Text("Delete"));
                                            }
                                            return SizedBox();
                                          }
                                        )
                                      ],
                                    ),
                                  ),
                            )
                          ),
                        );
                    }),
                ),
              ),
            ],
          );
      });
  }
  Future<void> expenseDetailsPopup(BuildContext context, String expenseId) async {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    User? user = FirebaseAuth.instance.currentUser;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
            Future usernamesFuture = viewModel.returnAssignedExpenseUsernamesList(expenseId);
            Future amountsFuture = viewModel.returnAssignedUsersAmountOwedList(expenseId);
            Future userIdsFuture = viewModel.returnAssignedExpenseUserIdsList(expenseId);
            return StatefulBuilder(builder: (context, setStates) {
              return AlertDialog(
                scrollable: true,
                title: Text('Expense Details'),
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
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(30),
                                        bottom: Radius.circular(30))),

                                child: FutureBuilder(
                                    future: Future.wait([usernamesFuture, amountsFuture, userIdsFuture]),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<dynamic>> snapshot) {
                                      if ("${snapshot.data}" == "null") {
                                        return const Text(
                                            ""); //Due to a delay in the username loading
                                      } else {
                                        return ListView.separated(
                                            padding: EdgeInsets.all(15),
                                            shrinkWrap: true,
                                            separatorBuilder: (context, index) {
                                              return SizedBox(height: 15);
                                            },
                                            itemCount: snapshot.data?[0]!.length,
                                            itemBuilder: (context, index) {
                                              TextEditingController enteredUserAmountController = TextEditingController();
                                              // double amountOwed = double.parse(snapshot.data?[1]![index]);
                                                  return Container(
                                                      decoration: BoxDecoration(
                                                          color: viewModel.colour1,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                      child: ListTile(
                                                        leading: Text(
                                                            "£" + snapshot.data?[1]![index],
                                                            style: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16)),
                                                        title: Text(
                                                            snapshot.data?[0]![index],
                                                            style: TextStyle(
                                                                color:
                                                                viewModel.colour4,
                                                                fontSize: 16)),

                                                        //TextField only shows if the current user owes money
                                                        subtitle: user?.uid == snapshot.data?[2][index]
                                                            ? TextField(
                                                          decoration: const InputDecoration(
                                                              hintText: "Amount Owed",
                                                              border: OutlineInputBorder()),
                                                          controller: enteredUserAmountController,
                                                        ) : null,

                                                          //Add Icon only shows if the current user owes money
                                                        trailing: user?.uid == snapshot.data?[2][index]
                                                            ? IconButton(
                                                            onPressed: () {
                                                              setState(() async {
                                                                if (enteredUserAmountController.text.isNotEmpty) {
                                                                  await viewModel.updateUserAmountPaid(
                                                                      expenseId,
                                                                      user!.uid,
                                                                      num.parse(enteredUserAmountController.text)
                                                                  );
                                                                }
                                                              });

                                              }, icon: Icon(Icons.add))
                                                            : null
                                                      ));
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
        });
  }
}