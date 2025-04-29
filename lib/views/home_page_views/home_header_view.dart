import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/pages/home_page.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/user_view_model.dart';

class HomeHeaderView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    bool isMobile = screenWidth < 600;

    GroupViewModel groupViewModel = GroupViewModel();
    User? user = FirebaseAuth.instance.currentUser;

    return Consumer<UserViewModel>(builder: (context, viewModel, child) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: IconButton(
              icon: Icon(
                Icons.menu,
                size: 42,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
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
                          child: Text("Home",
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: viewModel.colour4)),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          FutureBuilder<String?>(
              future: groupViewModel.returnGroupCode(user!.uid),
              builder: (BuildContext context,
                  AsyncSnapshot<String?> snapshot) {
                if ("${snapshot.data}" == "null") {
                  return const Text(
                      ""); //Due to a delay in the group code loading
                } else {
                  return Expanded(
                    flex: 1,
                    child: Align(
                      alignment: isMobile ? Alignment.centerRight : Alignment.bottomRight,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Column(
                            children: [
                              Text("Group Code:",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: viewModel.colour4)),
                              Text("${snapshot.data}",
                                  key: Key("groupCodeText"),
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: viewModel.colour4)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }),
        ],
      );
    });
  }
}
