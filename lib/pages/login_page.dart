import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/pages/create_account_page.dart';
import 'package:shared_accommodation_management_app/pages/create_or_join_group_page.dart';
import 'package:shared_accommodation_management_app/pages/home_page.dart';

import '../global/common/toast.dart';
import '../main.dart';
import '../user_auth/firebase_auth_functionality.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthFunctionality _auth = FirebaseAuthFunctionality();

  //Setting up the TextEditingControllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //Prevents memory leaks
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        resizeToAvoidBottomInset: false, //Stop overflow when keyboard opens
        body: createLoginPageBody(),
      ),
    );
  }

  SingleChildScrollView createLoginPageBody() {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return SingleChildScrollView(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(),
          child: Center(
            child: SizedBox(
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
          width: isMobile ? 300 : 400,
          child: TextField(
            key: const Key('emailField'),
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_rounded),
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
        const SizedBox(height: 15),
        SizedBox(
          width: isMobile ? 300 : 400,
          child: TextField(
            key: const Key('passwordField'),
              controller: _passwordController,
              obscureText: _isHidden,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.password_rounded),
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
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isHidden = !_isHidden;
                      });
                    },
                    icon: _isHidden
                        ? const Icon(
                      Icons.visibility_off,
                      color: Colors.grey,
                    )
                        : const Icon(
                      Icons.visibility,
                      color: Colors.black,
                    )
                ),
              )),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: isMobile ? 300 : 400,
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                key: const Key("forgotPasswordButton"),
                onPressed: () {
                  if (_emailController.text.isNotEmpty) {
                    sendForgotPasswordEmail(_emailController.text);
                  } else {
                    showToast(message: "Please enter an email address");
                  }
                },
                child: const Text("Forgot Password?", style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold))),
          ),
        ),

        //Spacing between the TextFields
        const SizedBox(height: 3),
        ElevatedButton(
          key: const Key("loginButton"),
            onPressed: () {
              _signIn();
            },
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.blue[800]!),
                foregroundColor:
                    WidgetStateProperty.resolveWith((state) => Colors.white),
                textStyle:
                    WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 30)),
                minimumSize: WidgetStateProperty.all<Size>(const Size(200, 90))),
            child: const Text("Login")),
        //Spacing between the login button and create account text
        const SizedBox(height: 15),

        const Center(
            child:
                Text("Don't have an account?", style: TextStyle(fontSize: 25))),
        TextButton(
          key: const Key("registerButton"),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CreateAccountPage()));
            },
            child: const Text("Create Account", style: TextStyle(fontSize: 25)))
      ],
    ));
  }

  void _signIn() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    final userDoc = await firestore.collection('users').doc(user?.uid).get(); //Gets the userId from the users collection
    //Checks if the current user is already in a group and displays the Home page if they are
    if (userDoc.exists && userDoc.data()?['groupId'] != null) {
      print("User was successfully signed in");

      //Checks firebase for the users darkMode setting
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      final isDark = doc.data()?['darkMode'] ?? false;
      MyApp.notifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    }
    else if (user != null) {
      print("User was successfully signed in");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const CreateOrJoinGroupPage()));
    } else {
      print("An error occurred");
    }
  }
  void sendForgotPasswordEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showToast(message: "Reset password email sent");

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast(message: "Invalid email");
      } else {
        showToast(message: "An error occurred: ${e.code}");
      }
    }
    return null;
  }
}
