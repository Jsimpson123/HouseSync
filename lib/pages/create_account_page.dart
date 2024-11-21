import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/pages/home_page.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  State<CreateAccountPage> createState() {
    return _CreateAccountPageState();
  }
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //Stop overflow when keyboard opens
      body: createRegisterPageBody(),
    );
  }

  SingleChildScrollView createRegisterPageBody() {
    return SingleChildScrollView(
      child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(),
          child: Center(
            child: Container(
              width: 200,
              height: 150,
              child: Image.asset('assets/images/housesync_logo.png'),
            ),
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        const Center(child: Text("Create Account", style: TextStyle(fontSize: 50))),
        //Spacing between the logo and TextFields
        const SizedBox(
          height: 25,
        ),
        TextField(
            decoration: InputDecoration(
              hintText: "User Name",
              filled: true,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green, width: 2.0)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(width: 2.0),
              ),
            )),
        //Spacing between the TextFields
        const SizedBox(height: 25),
        TextField(
            decoration: InputDecoration(
              hintText: "Email",
              filled: true,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green, width: 2.0)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(width: 2.0),
              ),
            )),
        //Spacing between the TextFields
        const SizedBox(height: 25),
        TextField(
            decoration: InputDecoration(
              hintText: "Password",
              filled: true,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green, width: 2.0)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(width: 2.0),
              ),
            )),
        //Spacing between the TextFields and login button
        const SizedBox(height: 25),
        ElevatedButton(
            onPressed: () {
              print("object");
            },
            child: Text("Register Now"),
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue[800]!),
                foregroundColor: WidgetStateProperty.resolveWith((state) => Colors.white),
                textStyle: WidgetStateProperty.all<TextStyle>(TextStyle(fontSize: 30)),
                minimumSize: WidgetStateProperty.all<Size>(Size(200,100))
            )
        )
      ],
    )
    );
  }
}
