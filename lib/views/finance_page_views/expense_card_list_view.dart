import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
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
                    // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 2,
                    //     crossAxisSpacing: 20,
                    //     mainAxisSpacing: 20,
                    //     // childAspectRatio: 8
                    // ),
                      scrollDirection: Axis.vertical,
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                    itemCount: viewModel.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = viewModel.expenses[index];
                        return Container(
                            decoration: BoxDecoration(
                                color: viewModel.colour1,
                                borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            leading: Icon(Icons.attach_money),
                            title: Container(width: 50,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Text(viewModel.getExpenseTitle(index),
                                        style: TextStyle(
                                            color: viewModel.colour4,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ),
                            subtitle: Container(width: 50,
                              child: FutureBuilder<String?>(
                                  future: viewModel.returnAssignedExpenseUsernames(expense.expenseId),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String?> snapshot) {
                                    if ("${snapshot.data}" == "null") {
                                      return const Text(
                                          ""); //Due to a delay in the username loading
                                    } else {
                                      return Align(
                                        alignment: Alignment.bottomLeft,
                                        child: FittedBox(
                                          fit: BoxFit.fitHeight,
                                          child: Text(
                                              "Assigned Users: \n${snapshot.data}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: viewModel.colour4)),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                            trailing: SizedBox(width: 100,
                              child: FutureBuilder<int?>(
                                  future: viewModel.returnAssignedExpenseAmount(expense.expenseId),
                                  builder: (BuildContext context,
                                        AsyncSnapshot<int?> snapshot) {
                                    if ("${snapshot.data}" == "null") {
                                      return const Text(
                                          ""); //Due to a delay in the username loading
                                    } else {
                                      return Align(
                                        alignment: Alignment.bottomRight,
                                        child: FittedBox(
                                          fit: BoxFit.fitHeight,
                                          child: Text(
                                              "Owed: \n${snapshot.data}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: viewModel.colour4)),
                                        ),
                                      );
                                    }
                                  }),
                            ),

                            onTap: () => expenseDetailsPopup(context, expense.expenseId),
                          )
                        );
                    }),
                ),
              ),
            ],
          );
      });
  }
  Future<void> expenseDetailsPopup(BuildContext context, String expenseId) async {
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
                title: Text('ExpenseDetails'),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: 200,
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
                                                  return Container(
                                                      decoration: BoxDecoration(
                                                          color: viewModel.colour1,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                      child: ListTile(
                                                        leading: Text(
                                                            snapshot.data?[1]![index]),
                                                        title: Text(
                                                            snapshot.data?[0]![index],
                                                            style: TextStyle(
                                                                color:
                                                                viewModel.colour4,
                                                                fontSize: 16)),

                                                        subtitle: user?.uid == snapshot.data?[2][index]
                                                            ? TextField(
                                                          decoration:
                                                          const InputDecoration(
                                                              hintText:
                                                              "Amount Owed",
                                                              border:
                                                              OutlineInputBorder()),
                                                          controller:
                                                          enteredUserAmountController,
                                                        ) : null,

                                                        trailing: IconButton(
                                                            onPressed: () async =>
                                                            await viewModel.updateUserAmountPaid(expenseId, user!.uid, double.parse(enteredUserAmountController.text)),
                                                            icon: Icon(
                                                                Icons.add)),
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