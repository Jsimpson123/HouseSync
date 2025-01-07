import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/group_functions_view.dart';

class CreateOrJoinGroupPage extends StatefulWidget {
  @override
  State<CreateOrJoinGroupPage> createState() {
    return _CreateOrJoinGroupPageState();
  }
}

class _CreateOrJoinGroupPageState extends State<CreateOrJoinGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: GroupFunctionsView())
    );
  }
}