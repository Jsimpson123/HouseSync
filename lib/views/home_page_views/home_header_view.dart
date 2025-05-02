import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/global/common/AppColours.dart';
import 'package:shared_accommodation_management_app/view_models/group_view_model.dart';
import 'package:shared_accommodation_management_app/view_models/user_view_model.dart';

class HomeHeaderView extends StatelessWidget {
  const HomeHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    //Calculates if the theme is light/dark mode
    final brightness = Theme.of(context).brightness;

    GroupViewModel groupViewModel = GroupViewModel();
    User? user = FirebaseAuth.instance.currentUser;

    return Consumer<UserViewModel>(builder: (context, viewModel, child) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: IconButton(
              icon: const Icon(
                Icons.menu,
                size: 42,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          const SizedBox(
            width: 25,
          ),
          const Icon(
            Icons.home,
            size: 45,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
              flex: 2,
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
                                color: AppColours.colour4(brightness))),
                      ),
                    ),
                  ),
                ],
              )),
          FutureBuilder<String?>(
              future: groupViewModel.returnGroupCode(user!.uid),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if ("${snapshot.data}" == "null") {
                  return const Text(""); //Due to a delay in the group code loading
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
                                      color: AppColours.colour4(brightness))),
                              Text("${snapshot.data}",
                                  key: const Key("groupCodeText"),
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColours.colour4(brightness))),
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
