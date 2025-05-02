import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';

import '../../global/common/AppColours.dart';
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
    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
      return Column(
        children: [
          Expanded(
            child: Container(
                decoration: BoxDecoration(
                    color: AppColours.colour2(brightness),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
                child: viewModel.expenses.isNotEmpty
                    ? GridView.builder(
                        padding: const EdgeInsets.all(15),
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
                                    color: AppColours.colour1(brightness),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Card(
                                  color: brightness == Brightness.light
                                      ? Colors.white
                                      : AppColours.colour1(brightness),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: Text(viewModel.getExpenseTitle(index),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: AppColours.colour4(brightness),
                                                        fontSize: isMobile ? 20 : 24,
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: isMobile ? 10 : 15),
                                        Center(
                                          child: FutureBuilder<num?>(
                                              future: viewModel
                                                  .returnAssignedExpenseAmount(expense.expenseId),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<num?> snapshot) {
                                                if ("${snapshot.data}" == "null") {
                                                  return const Text(
                                                      ""); //Due to a delay in the amount loading
                                                } else if (num.parse("${snapshot.data}") <= 0) {
                                                  viewModel.deleteExpense(expense.expenseId);
                                                  setState(() async {
                                                    const SizedBox.shrink();
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((_) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const FinancePage()));
                                                    });
                                                  });
                                                  return const SizedBox();
                                                } else {
                                                  return FittedBox(
                                                    fit: BoxFit.fitHeight,
                                                    child: Text(
                                                        "£${num.tryParse("${snapshot.data}")!.toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                            fontSize: isMobile ? 20 : 24,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.red)),
                                                  );
                                                }
                                              }),
                                        ),
                                        SizedBox(height: isMobile ? 10 : 12),
                                        Icon(Icons.supervisor_account_sharp,
                                            size: isMobile ? 25 : 45),
                                        Center(
                                          child: FutureBuilder<List?>(
                                              future: viewModel.returnAssignedExpenseUsernamesList(
                                                  expense.expenseId),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<List?> snapshot) {
                                                if ("${snapshot.data}" == "null") {
                                                  return const Text(
                                                      ""); //Due to a delay in the username loading
                                                } else {
                                                  List assignedUsers = snapshot.data!;

                                                  //Can overflow if takes up too much space
                                                  return Wrap(
                                                    spacing: 8,
                                                    runSpacing: 4,
                                                    children: [
                                                      for (int i = 0; i < assignedUsers.length; i++)
                                                        Chip(
                                                          avatar: const Icon(Icons.account_box),
                                                          label: Text(assignedUsers[i],
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                                color:
                                                                    AppColours.colour4(brightness),
                                                              )),
                                                          backgroundColor:
                                                              brightness == Brightness.light
                                                                  ? Colors.lightBlue[100]
                                                                  : Colors.blue[900],
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 8, vertical: 4),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(20),
                                                            side: BorderSide(
                                                                color: Colors.grey.shade300),
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                }
                                              }),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        FutureBuilder(
                                            future:
                                                viewModel.returnExpenseCreatorId(expense.expenseId),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String?> snapshot) {
                                              if (user?.uid == snapshot.data) {
                                                return ElevatedButton(
                                                    onPressed: () {
                                                      viewModel.deleteExpenseUponClick(index);
                                                      showToast(message: "Expense Deleted!");
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        foregroundColor:
                                                            AppColours.colour1(brightness),
                                                        backgroundColor: Colors.red,
                                                        textStyle: const TextStyle(
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(20))),
                                                    child: const Text("Delete"));
                                              }
                                              return const SizedBox();
                                            })
                                      ],
                                    ),
                                  ),
                                )),
                          );
                        })
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.attach_money, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              "All expenses paid off!",
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
                      )),
          ),
        ],
      );
    });
  }

  Future<void> expenseDetailsPopup(BuildContext context, String expenseId) async {
    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

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
                title: SizedBox(
                  width: double.maxFinite,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Expense Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 24),
                          )),
                      Column(
                        children: [
                          Text(
                            "Expense Creator:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 24),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Chip(
                              avatar: const Icon(Icons.account_box),
                              label: FutureBuilder<String?>(
                                  future: viewModel.returnExpenseCreatorName(expenseId),
                                  builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                    if ("${snapshot.data}" == "null") {
                                      return const Text(
                                          ""); //Due to a delay in the username loading
                                    } else {
                                      return Expanded(
                                        child: Text("${snapshot.data}",
                                            style: TextStyle(
                                                fontSize: isMobile ? 12 : 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green)),
                                      );
                                    }
                                  }),
                              backgroundColor: brightness == Brightness.light
                                  ? Colors.lightBlue[100]
                                  : Colors.blue[900],
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                                        future: Future.wait(
                                            [usernamesFuture, amountsFuture, userIdsFuture]),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<dynamic>> snapshot) {
                                          if ("${snapshot.data}" == "null") {
                                            return const Text(
                                                ""); //Due to a delay in the username loading
                                          } else {
                                            return ListView.separated(
                                                padding: const EdgeInsets.all(15),
                                                shrinkWrap: true,
                                                separatorBuilder: (context, index) {
                                                  return const SizedBox(height: 15);
                                                },
                                                itemCount: snapshot.data?[0]!.length,
                                                itemBuilder: (context, index) {
                                                  TextEditingController
                                                      enteredUserAmountController =
                                                      TextEditingController();
                                                  return Container(
                                                      decoration: BoxDecoration(
                                                          color: AppColours.colour1(brightness),
                                                          borderRadius: BorderRadius.circular(20)),
                                                      child: ListTile(
                                                          //Prevents overflow
                                                          dense: true,
                                                          contentPadding: const EdgeInsets.fromLTRB(
                                                              10, 0, 0, 0),
                                                          title: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.account_box,
                                                                    size: isMobile ? 20 : 24,
                                                                  ),
                                                                  const SizedBox(width: 2),
                                                                  Expanded(
                                                                    child: Text(
                                                                      snapshot.data?[0]![index],
                                                                      style: TextStyle(
                                                                          color: AppColours.colour4(
                                                                              brightness),
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              isMobile ? 16 : 18),
                                                                      softWrap: false,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                  "£${num.tryParse(snapshot.data?[1]![index])!.toStringAsFixed(2)}",
                                                                  style: TextStyle(
                                                                      color: Colors.red,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize:
                                                                          isMobile ? 14 : 16)),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              if (user?.uid ==
                                                                  snapshot.data?[2][index])
                                                                TextField(
                                                                  decoration: const InputDecoration(
                                                                      hintText: "Paid",
                                                                      border: OutlineInputBorder()),
                                                                  controller:
                                                                      enteredUserAmountController,
                                                                  keyboardType: const TextInputType
                                                                      .numberWithOptions(
                                                                      decimal: true),
                                                                  inputFormatters: [
                                                                    //Regex to insure invalid user inputs cant be entered
                                                                    FilteringTextInputFormatter
                                                                        .allow(RegExp(
                                                                            r'^\d*\.?\d{0,2}$')),
                                                                  ],
                                                                )
                                                            ],
                                                          ),

                                                          //Pay Icon only shows if the current user owes money
                                                          trailing: user?.uid ==
                                                                  snapshot.data?[2][index]
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets.fromLTRB(
                                                                          0, 0, 10, 0),
                                                                  child: ElevatedButton(
                                                                    onPressed: () {
                                                                      setState(() async {
                                                                        num? convertedAmount =
                                                                            num.tryParse(
                                                                                enteredUserAmountController
                                                                                    .text);

                                                                        if (enteredUserAmountController
                                                                                .text.isNotEmpty &&
                                                                            convertedAmount != 0 &&
                                                                            convertedAmount !=
                                                                                null) {
                                                                          num? existingAmount =
                                                                              num.tryParse(
                                                                                  snapshot.data?[
                                                                                      1]![index]);

                                                                          double
                                                                              convertedAmountRounded =
                                                                              double.parse(
                                                                                  convertedAmount
                                                                                      .toStringAsFixed(
                                                                                          2));
                                                                          double
                                                                              existingAmountRounded =
                                                                              double.parse(
                                                                                  existingAmount!
                                                                                      .toStringAsFixed(
                                                                                          2));

                                                                          if (convertedAmountRounded <=
                                                                              existingAmountRounded) {
                                                                            await viewModel
                                                                                .updateUserAmountPaid(
                                                                                    expenseId,
                                                                                    user!.uid,
                                                                                    convertedAmountRounded);
                                                                          } else {
                                                                            showToast(
                                                                                message:
                                                                                    "Overpaid! Please enter a valid amount");
                                                                          }
                                                                        } else {
                                                                          showToast(
                                                                              message:
                                                                                  "Invalid amount entered");
                                                                        }
                                                                      });
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                        foregroundColor: AppColours
                                                                            .colour1(brightness),
                                                                        backgroundColor: Colors
                                                                            .green,
                                                                        textStyle: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            fontSize: 16),
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                    BorderRadius
                                                                                        .circular(
                                                                                            20))),
                                                                    child: const Text("Pay"),
                                                                  ),
                                                                )
                                                              : null));
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
        });
  }
}
