import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/finance_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/shopping_view_model.dart';

class FinanceInfoView extends StatelessWidget {
  const FinanceInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceViewModel>(builder: (context, viewModel, child) {
      return Container(
        margin: EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Row(
          children: [
            //Total Expenses
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                    color: viewModel.colour2, borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          "${viewModel.numExpenses}",
                          style: TextStyle(
                              fontSize: 28,
                              color: viewModel.colour3,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FittedBox(
                        child: Text("Total Expenses", style: TextStyle(
                            color: viewModel.colour4, fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}
