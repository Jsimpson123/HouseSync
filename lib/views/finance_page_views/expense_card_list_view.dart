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
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
        return Card(
          child: Column(
            children: [
              // Text(viewModel.returnExpenseName(expenseId))
            ],
          ),
        );
      });
  }
}