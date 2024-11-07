import 'package:flutter/material.dart';

class AppBarDisplay extends StatelessWidget implements PreferredSizeWidget {
  final String title = "HouseSync";
  const AppBarDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    //Creates the AppBar
    return AppBar(
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.indigo,
              height: 4.0,
            )),
      title: Text(title), //Sets the title
      centerTitle: true, //Centers the title
      automaticallyImplyLeading: false, //Removes built-in back button
    );

  }
  @override
  Size get preferredSize => const Size.fromHeight(60);
}