import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';

class ShoppingHeaderView extends StatelessWidget {
  const ShoppingHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(builder: (context, viewModel, child) {
      return Row(
        children: [
          Expanded(
              flex: 2,
              child: Container(
                margin: EdgeInsets.only(left: 15),
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
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
        ],
      );
    });
  }
}
