import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/side_bar.dart';

import '../../view_models/home_view_model.dart';
import '../../view_models/task_view_model.dart';
import 'bottom_sheets/create_group_bottom_sheet_view.dart';

class HomeHeaderView extends StatelessWidget {
  const HomeHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(builder: (context, viewModel, child) {
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
                        alignment: Alignment.topLeft,
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
                                alignment: Alignment.topLeft,
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
                        }),
                  ],
                ),
              )),
      // Expanded(
      //     flex: 3,
      //     child: Align(
      //       alignment: Alignment.centerRight,
      //       // child: Drawer(
      //         child: InkWell( onTap: () {
      //           viewModel.displayBottomSheet(CreateGroupBottomSheetView(), context);
      //
      //         },
      //             child: Icon(Icons.group_add_outlined, size: 80,)),
      //       // ),
      //     )),
        ],
      );
    });
  }
}
