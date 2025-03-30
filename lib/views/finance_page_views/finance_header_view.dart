import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
import 'package:shared_accommodation_management_app/views/finance_page_views/expense_card_list_view.dart';

import 'expense_records_view.dart';

class FinanceHeaderView extends StatelessWidget {
  const FinanceHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    ExpenseCardListView expenseCardListView = ExpenseCardListView();
    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(left: 15),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text("Finance",
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: viewModel.colour4)),
                        ),
                      ),
                    )
                  ],
                ),
              )),
          Container(
            margin: EdgeInsets.only(right: 100),
            child: InkWell( onTap: () {
              ExpenseRecordsView.expenseRecordsPopup(context, ExpenseRecordsView());
            },
                child: Icon(Icons.calendar_month, size: 40)),
          ),
        ],
      );
    });
  }
}
