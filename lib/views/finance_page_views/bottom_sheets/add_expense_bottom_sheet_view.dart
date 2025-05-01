import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';
import 'package:shared_accommodation_management_app/models/finance_model.dart';
import 'package:shared_accommodation_management_app/pages/finance_page.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';

import '../../../global/common/AppColours.dart';
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

num remainingExpenseAmount = 0;
num initialExpenseAmount = 0;

List<String> assignedUsers = <String>[];

List<Map<String, dynamic>> assignedUserIds = [];
List<Map<String, dynamic>> assignedUsersRecord = [];

List<Map<String, dynamic>> userPayments = [];

bool isAddButtonEnabled() {
  return enteredExpenseNameController.text.isNotEmpty;
}

bool isSubmitButtonEnabled() {
  return enteredExpenseNameController.text.isNotEmpty &&
      assignedUserIds.isNotEmpty;
}

FinanceViewModel financeViewModel = FinanceViewModel();

class _AddExpenseBottomSheetView extends State<AddExpenseBottomSheetView> {
  @override
  Widget build(BuildContext context) {
    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

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

                  const SizedBox(height: 15),

                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          ("£$remainingExpenseAmount"),
                          style: TextStyle(
                              fontSize: 28,
                              color: AppColours.colour3(brightness),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  //Assign Users Button
                  IconButton(
                      icon: const Icon(Icons.group_add),
                      iconSize: 30,
                      onPressed: !isAddButtonEnabled()
                          ? null
                          : () => assignUsersToExpensePopup(context)),

                  const SizedBox(height: 10),

                  //Submit Button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColours.colour3(brightness),
                          foregroundColor: AppColours.colour1(brightness),
                          fixedSize: const Size(150, 100)),
                      onPressed: !isSubmitButtonEnabled()
                          ? null
                          : () async {
                              //If the required fields have data then create the expense
                              if (enteredExpenseNameController
                                      .text.isNotEmpty &&
                                  initialExpenseAmount > 0 &&
                                  assignedUserIds.isNotEmpty) {
                                Expense newExpense = Expense.newExpense(
                                    user!.uid,
                                    enteredExpenseNameController.text,
                                    initialExpenseAmount,
                                    remainingExpenseAmount,
                                    assignedUserIds,
                                    assignedUsersRecord);

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
                                  initialExpenseAmount = 0;
                                  remainingExpenseAmount = 0;
                                });
                              }

                              //Refreshes the page to allow users to be visible again when assigning
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const FinancePage()));
                            },
                      child: const Text("Submit"))
                ],
              )));
    });
  }

  Future<void> assignUsersToExpensePopup(BuildContext context) async {
    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
            return StatefulBuilder(builder: (context, setStates) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Add Users'),
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
                                    color: AppColours.colour2(brightness),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(30),
                                        bottom: Radius.circular(30))),
                                child: ListView.separated(
                                    padding: const EdgeInsets.all(15),
                                    shrinkWrap: true,
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(height: 15);
                                    },
                                    itemCount: viewModel.members.length,
                                    itemBuilder: (context, index) {
                                      String member = viewModel.memberIds[index];
                                      TextEditingController
                                          enteredUserAmountController =
                                          TextEditingController();
                                      return GestureDetector(
                                          key: UniqueKey(),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: AppColours.colour1(brightness),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: user?.uid != member
                                                  ? ListTile(
                                                      title: Row(
                                                        children: [
                                                          Icon(Icons.account_box,
                                                              size: isMobile ? 18 : 24),
                                                          const SizedBox(width: 2),
                                                          Expanded(
                                                            child: Text(
                                                                viewModel.members[index],
                                                                style: TextStyle(
                                                                    color: AppColours.colour4(brightness),
                                                                    fontSize: isMobile? 14 : 16),
                                                              maxLines: 1,
                                                              softWrap: false,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      //Assignment or unassignment button
                                                      trailing: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                             IconButton(
                                                                    //If user is assigned
                                                                    onPressed:
                                                                        () {
                                                                      if (enteredUserAmountController
                                                                              .text
                                                                              .isEmpty ||
                                                                          enteredUserAmountController.text ==
                                                                              "0") {
                                                                        showToast(
                                                                            message:
                                                                                "Please enter the amount owed");
                                                                      } else {
                                                                        showToast(
                                                                            message:
                                                                                "Assigned: ${viewModel.members[index]}");

                                                                        setState(
                                                                            () {
                                                                          if (num.parse(enteredUserAmountController.text) >
                                                                              0) {
                                                                            assignedUserIds.add({
                                                                              'userId': viewModel.memberIds[index],
                                                                              'amount': num.tryParse(enteredUserAmountController.text)
                                                                            });

                                                                            assignedUsersRecord.add({
                                                                              'userId': viewModel.memberIds[index],
                                                                              'userName': viewModel.members[index],
                                                                              'initialAmountOwed': num.parse(enteredUserAmountController.text),
                                                                              'remainingAmountOwed': num.parse(enteredUserAmountController.text),
                                                                              'paidOff': false,
                                                                              'payments': userPayments
                                                                            });
                                                                          }
                                                                          viewModel
                                                                              .removeMember(index);
                                                                          initialExpenseAmount =
                                                                              initialExpenseAmount + num.parse(enteredUserAmountController.text);
                                                                          remainingExpenseAmount =
                                                                              initialExpenseAmount;
                                                                        });
                                                                      }
                                                                    },
                                                                    icon: Icon(Icons.check,
                                                                      size: isMobile ? 18 :24
                                                                    ),
                                                              padding: EdgeInsets.zero,
                                                                constraints: const BoxConstraints.tightFor(width: 16, height: 16)
                                                                  )
                                                          ]),

                                                      subtitle: TextField(
                                                            decoration: const InputDecoration(
                                                                hintText: "Owed",
                                                                border: OutlineInputBorder(),
                                                            ),
                                                            controller: enteredUserAmountController,
                                                            keyboardType: const TextInputType
                                                                .numberWithOptions(
                                                                    decimal:
                                                                        true),
                                                            inputFormatters: [
                                                              //Regex to insure invalid user inputs cant be entered
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      r'^\d*\.?\d{0,2}$')),
                                                            ],
                                                          )
                                                          // : null,
                                                    )
                                                  : null));
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
