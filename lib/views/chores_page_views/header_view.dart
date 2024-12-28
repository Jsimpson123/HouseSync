import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/task_view_model.dart';
import 'bottom_sheets/delete_task_bottom_sheet_view.dart';

class HeaderView extends StatelessWidget {
  const HeaderView({super.key});

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
                        alignment: Alignment.bottomLeft,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text("Welcome",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                  color: viewModel.colour4)),
                        ),
                      ),
                    ),
                    FutureBuilder<String?>(
                        future: viewModel.returnCurrentUsername(),
                        builder: (BuildContext context,
                            AsyncSnapshot<String?> snapshot) {
                          if ("${snapshot.data}" == "null") {
                            return const Text(
                                ""); //Due to a delay in the username loading
                          } else {
                            return Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: Text("${snapshot.data}",
                                      style: TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: viewModel.colour4)),
                                ),
                              ),
                            );
                          }
                        })
                  ],
                ),
              )),
          // Delete Icon
          Expanded(
              flex: 1,
              child: InkWell( onTap: () {
                viewModel.displayBottomSheet(DeleteTaskBottomSheetView(), context);
              },
              child: Icon(Icons.delete, size: 40,))),
        ],
      );
    });
  }
}
