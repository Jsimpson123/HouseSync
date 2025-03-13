import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/pages/create_account_page.dart';
import 'package:shared_accommodation_management_app/pages/create_or_join_group_page.dart';
import 'package:shared_accommodation_management_app/pages/home_page.dart';

import '../global/common/toast.dart';
import '../user_auth/firebase_auth_functionality.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthFunctionality _auth = FirebaseAuthFunctionality();

  //Setting up the TextEditingControllers
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  //Prevents memory leaks
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //Stop overflow when keyboard opens
      body: createLoginPageBody(),
    );
  }

  SingleChildScrollView createLoginPageBody() {
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
        // const SizedBox(
        //   height: 10,
        // ),
        const Center(child: Text("Welcome", style: TextStyle(fontSize: 50))),
        const Center(
            child:
                Text("Sign into your account", style: TextStyle(fontSize: 25))),
        //Spacing between the logo and TextFields
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: 750,
          child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_rounded),
                hintText: "Email",
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Colors.green, width: 2.0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(width: 2.0),
                ),
              )),
        ),
        //Spacing between the TextFields and login button
        const SizedBox(height: 25),
        SizedBox(
          width: 750,
          child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.password_rounded),
                hintText: "Password",
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: Colors.green, width: 2.0)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(width: 2.0),
                ),
              )),
        ),
        //Spacing between the TextFields
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: () {
              _signIn();
            },
            child: Text("Login"),
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.blue[800]!),
                foregroundColor:
                    WidgetStateProperty.resolveWith((state) => Colors.white),
                textStyle:
                    WidgetStateProperty.all<TextStyle>(TextStyle(fontSize: 30)),
                minimumSize: WidgetStateProperty.all<Size>(Size(200, 100)))),
        //Spacing between the login button and create account text
        const SizedBox(height: 15),

        const Center(
            child:
                Text("Don't have an account?", style: TextStyle(fontSize: 25))),
        TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateAccountPage()));
            },
            child: const Text("Create Account", style: TextStyle(fontSize: 25)))
      ],
    ));
  }

  void _signIn() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    final userDoc = await _firestore.collection('users').doc(user?.uid).get(); //Gets the userId from the users collection
    //Checks if the current user is already in a group and displays the Home page if they are
    if (userDoc.exists && userDoc.data()?['groupId'] != null) {
      print("User was successfully signed in");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
    else if (user != null) {
      print("User was successfully signed in");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateOrJoinGroupPage()));
    } else {
      print("An error occured");
    }
  }
}
