import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/pages/create_account_page.dart';
import 'package:shared_accommodation_management_app/pages/home_page.dart';

import '../user_auth/firebase_auth_functionality.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {

  //FirebaseAuthFunctionality instance
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
        const SizedBox(
          height: 10,
        ),
        const Center(child: Text("Welcome", style: TextStyle(fontSize: 50))),
        const Center(child: Text("Sign into your account", style: TextStyle(fontSize: 25))),
        //Spacing between the logo and TextFields
        const SizedBox(
          height: 25,
        ),
        TextField(
          controller: _emailController,
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
        //Spacing between the TextFields and login button
        const SizedBox(height: 25),
        TextField(
          controller: _passwordController,
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
        //Spacing between the TextFields
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: () {
            _signIn();
          },
          child: Text("Login"),
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.blue[800]!),
              foregroundColor: WidgetStateProperty.resolveWith((state) => Colors.white),
              textStyle: WidgetStateProperty.all<TextStyle>(TextStyle(fontSize: 30)),
              minimumSize: WidgetStateProperty.all<Size>(Size(200,100))
          )
        ),
        //Spacing between the login button and create account text
        const SizedBox(height: 50),

        const Center(child: Text("Don't have an account?", style: TextStyle(fontSize: 25))),
        TextButton(
            onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(
              builder: (context) => CreateAccountPage()
              )
          );
        },
            child: const Text("Create Account", style: TextStyle(fontSize: 25)))
      ],
    )
    );
  }

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if(user != null) {
      print("User was successfully signed in");
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()
      )
      );
    } else {
      print("An error occured");
    }
  }
}
