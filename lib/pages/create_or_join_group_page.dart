import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/group_functions_view.dart';

class CreateOrJoinGroupPage extends StatefulWidget {
  const CreateOrJoinGroupPage({super.key});

  @override
  State<CreateOrJoinGroupPage> createState() {
    return _CreateOrJoinGroupPageState();
  }
}

class _CreateOrJoinGroupPageState extends State<CreateOrJoinGroupPage> {
  @override
  Widget build(BuildContext context) {
    //Theme is always light as user hasn't had the ability to change it yet
    return Theme(
      data: ThemeData.light(),
      child: const Scaffold(body: Center(child: GroupFunctionsView())),
    );
  }
}
