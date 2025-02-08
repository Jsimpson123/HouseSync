import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';
import 'package:shared_accommodation_management_app/models/finance_model.dart';
import 'package:shared_accommodation_management_app/pages/finance_page.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../../view_models/finance_view_model.dart';

class AddExpenseBottomSheetView extends StatefulWidget {
  const AddExpenseBottomSheetView({super.key});

  @override
  State<AddExpenseBottomSheetView> createState() {
    return _AddExpenseBottomSheetView();
  }
}

GroupViewModel groupViewModel = GroupViewModel();

User? user = FirebaseAuth.instance.currentUser;

final TextEditingController enteredExpenseNameController =
TextEditingController();
final TextEditingController enteredExpenseAmountController =
TextEditingController();

List<TextEditingController> controllers = [];

double totalAmountOwed = 0;

List<String> assignedUsers = <String>[];

List<Map<String, dynamic>> assignedUserIds = [];

bool isAddButtonEnabled() {
  return enteredExpenseNameController.text.isNotEmpty;
}

bool isSubmitButtonEnabled() {
  return enteredExpenseNameController.text.isNotEmpty
      &&
      assignedUserIds.isNotEmpty;
}

FinanceViewModel financeViewModel = FinanceViewModel();

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

                  //ExpenseName
                  TextField(
                      decoration: const InputDecoration(
                          hintText: "Expense Name",
                          border: OutlineInputBorder()),
                      controller: enteredExpenseNameController,
                      onChanged: (_) => setState(() {})),

                  SizedBox(height: 15),

                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          "$totalAmountOwed",
                          style: TextStyle(
                              fontSize: 28,
                              color: viewModel.colour3,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  //Assign Users Button
                  IconButton(
                      icon: Icon(Icons.group_add),
                      iconSize: 30,
                      onPressed: !isAddButtonEnabled()
                          ? null
                          : () => assignUsersToExpensePopup(context)),

                  SizedBox(height: 10),

                  //Submit Button
                  ElevatedButton(
                      child: Text("Submit"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: viewModel.colour3,
                          foregroundColor: viewModel.colour1,
                          fixedSize: Size(150, 100)),
                      onPressed: !isSubmitButtonEnabled()
                          ? null
                          : ()  async {
                        //If the required fields have data then create the expense
                        if (enteredExpenseNameController.text.isNotEmpty
                            && totalAmountOwed > 0
                            && assignedUserIds.isNotEmpty)
                          {
                            Expense newExpense = Expense.newExpense(user!.uid, enteredExpenseNameController.text, totalAmountOwed, assignedUserIds);

                            //Sending data to the db
                            await viewModel.createExpense(newExpense);

                            setState(() {
                              //Resets everything to ensure values don't remain when creating a new expense
                              Navigator.of(context).pop();
                              enteredExpenseNameController.clear();
                              enteredExpenseAmountController.clear();
                              assignedUsers.clear();
                              assignedUserIds.clear();
                              controllers.clear();
                              totalAmountOwed = 0;
                            });
                          }

                        //Refreshes the page to allow users to be visible again when assigning
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FinancePage()));
                      })
                ],
              )));
    });
  }

  Future<void> assignUsersToExpensePopup(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
            return StatefulBuilder(builder: (context, setStates) {
              return AlertDialog(
                scrollable: true,
                title: Text('Add Users'),
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
                                child: ListView.separated(
                                    padding: EdgeInsets.all(15),
                                    shrinkWrap: true,
                                    separatorBuilder: (context, index) {
                                      return SizedBox(height: 15);
                                    },
                                    itemCount: viewModel.members.length,
                                    itemBuilder: (context, index) {
                                      String member =
                                      viewModel.memberIds[index];
                                      bool isAssigned =
                                      assignedUsers.contains(member);
                                      TextEditingController
                                      enteredUserAmountController = TextEditingController();
                                      return GestureDetector(
                                          key: UniqueKey(),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: viewModel.colour1,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      20)),
                                              child: ListTile(
                                                title: Text(
                                                    viewModel.members[index],
                                                    style: TextStyle(
                                                        color:
                                                        viewModel.colour4,
                                                        fontSize: 16)),

                                                //Assignment or unassignment button
                                                trailing: Wrap(
                                                    spacing: 12,
                                                    children: <Widget>[
                                                      isAssigned
                                                          ? IconButton(
                                                        //If user is assigned
                                                          onPressed: () {
                                                            setStates(() {
                                                              int index = assignedUsers.indexOf(member);
                                                              assignedUsers.remove(member);
                                                              controllers.removeAt(index);
                                                            });
                                                          },
                                                          icon: Icon(Icons
                                                              .remove_circle))
                                                          : IconButton(
                                                        //If user isn't assigned
                                                          onPressed: () {
                                                            setStates(() {
                                                              assignedUsers
                                                                  .add(
                                                                  member);
                                                              controllers.add(
                                                                  TextEditingController());
                                                            });
                                                          },
                                                          icon: Icon(Icons
                                                              .add_box)),
                                                      isAssigned
                                                          ? IconButton(
                                                        //If user is assigned
                                                        onPressed: () {
                                                          if (enteredUserAmountController.text.isEmpty) {
                                                            showToast(message: "Please enter the amount owed");
                                                          } else {
                                                            showToast(message: "Assigned: ${viewModel.members[index]}");

                                                            setState(() {
                                                              if (double.parse(enteredUserAmountController.text) > 0) {
                                                                assignedUserIds.add({
                                                                  'userId': viewModel.memberIds[index],
                                                                  'amount': enteredUserAmountController.text
                                                                });
                                                              }
                                                              viewModel.removeMember(index);
                                                              totalAmountOwed = totalAmountOwed + double.parse(enteredUserAmountController.text);
                                                            });
                                                          }
                                                        },
                                                        icon: Icon(
                                                            Icons.check),
                                                      )
                                                          : SizedBox.shrink()
                                                    ]),

                                                subtitle: isAssigned
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

                                              )));
                                    }),
                              ),
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
