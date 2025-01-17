import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../../view_models/finance_view_model.dart';

class AddExpenseBottomSheetView extends StatelessWidget {

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final TextEditingController enteredExpenseNameController = TextEditingController();

    return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
      return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom), //Ensures the keyboard doesn't cover the textfields
          child: Container(
              height: 300,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                        hintText: "Expense Name", border: OutlineInputBorder()),
                    controller: enteredExpenseNameController,
                    // onSubmitted: (value) {
                    //   if (enteredExpenseNameController.text.isNotEmpty) {
                    //     Expense newExpense = Expense.newExpense(.text);
                    //     viewModel.addExpense(newExpense)
                    //     .clear();
                    //   }
                    //   Navigator.of(context).pop(); //Makes bottom expense bar disappear
                    // }
                  ),

                  TextField(
                    decoration: const InputDecoration(
                        hintText: "Expense Amount",
                        border: OutlineInputBorder()),
                    controller: enteredExpenseNameController,
                    // onSubmitted: (value) {
                    //   if (enteredExpenseNameController.text.isNotEmpty) {
                    //     Expense newExpense = Expense.newExpense(.text);
                    //     viewModel.addExpense(newExpense)
                    //     .clear();
                    //   }
                    //   Navigator.of(context).pop(); //Makes bottom expense bar disappear
                    // }
                  ),

                  IconButton(
                    icon: Icon(Icons.add), onPressed: () {
                    assignUsersToExpensePopup(context);
                  },),
                ],
              )));
    });
  }

  Future<void> assignUsersToExpensePopup(BuildContext context) async {
    // GroupViewModel groupViewModel = GroupViewModel();
    //
    // int membersSize = groupViewModel.returnGroupMembersSize(user!.uid) as int;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<GroupViewModel>(
              builder: (BuildContext context, viewModel, child) {
                return AlertDialog(
                  scrollable: true,
                  title: Text('Add Users'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        child: Column(
                          children: <Widget>[
                            ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 15);
                              },
                              itemCount: viewModel.members.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                      color: viewModel.colour1,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ListTile(
                                    title: Text(viewModel.members[index].toString(),
                                        style:
                                        TextStyle(color: viewModel.colour4, fontSize: 16)),
                                  ),
                                );

                              }
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                        child: Text("Submit"),
                        onPressed: () {
                          // your code
                        })
                  ],
                );
              });
        });
  }
}