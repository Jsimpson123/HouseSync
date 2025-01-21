import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../../view_models/finance_view_model.dart';

class AddExpenseBottomSheetView extends StatefulWidget {
  @override
  State<AddExpenseBottomSheetView> createState() {
    return _AddExpenseBottomSheetView();
  }
}
  User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController enteredExpenseNameController =
      TextEditingController();
  final TextEditingController enteredExpenseAmountController =
      TextEditingController();

  bool isButtonEnabled() {
    return enteredExpenseNameController.text.isNotEmpty
    && enteredExpenseAmountController.text.isNotEmpty;
  }

FinanceViewModel financeViewModel = FinanceViewModel();
  GroupViewModel groupViewModel = GroupViewModel();

List<String> assignedUsers = <String>[];

  class _AddExpenseBottomSheetView extends State<AddExpenseBottomSheetView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
      return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
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
                    onChanged: (_) => setState(() {
                    })),

                  TextField(
                    decoration: const InputDecoration(
                        hintText: "Expense Amount",
                        border: OutlineInputBorder()),
                    controller: enteredExpenseAmountController,
                    onChanged: (_) => setState(() {
                    })),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => isButtonEnabled() ? assignUsersToExpensePopup(context) : null),

                  ElevatedButton(
                      child: Text("Submit"),
                      onPressed: () => {
                        if (enteredExpenseNameController.text.isNotEmpty &&
                            enteredExpenseAmountController.text.isNotEmpty &&
                        assignedUsers.isNotEmpty) {
                          financeViewModel.createExpense(
                              user!.uid,
                              enteredExpenseNameController.text,
                              double.tryParse(enteredExpenseAmountController.text) ?? 0.0,
                              assignedUsers),

                          Navigator.of(context).pop(),

                          enteredExpenseNameController.clear(),
                          enteredExpenseAmountController.clear(),
                          // assignedUsers.clear()
                        },
                        // setState(() {
                        //   groupViewModel.members.addAll(assignedUsers);
                        // })
                      }
                  )
                ],
              )));
    });
  }

  Future<void> assignUsersToExpensePopup(BuildContext context) async {
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
                                      onTap: () => {
                                            assignedUsers.add(viewModel.members[index]),
                                        showToast(message: "Assigned: ${viewModel.members[index]}"),

                                        setState(() {
                                      viewModel.removeMember(index);
                                        })
                                          }),
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
