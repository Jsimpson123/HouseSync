import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/user_model.dart';
import 'package:shared_accommodation_management_app/pages/home_page.dart';
import 'package:shared_accommodation_management_app/user_auth/firebase_auth_functionality.dart';
import 'package:shared_accommodation_management_app/view_models/user_view_model.dart';

import '../global/common/toast.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() {
    return _CreateAccountPageState();
  }
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  FirebaseAuthFunctionality firebaseAuthFunctionality =
      new FirebaseAuthFunctionality();

  //FirebaseAuthFunctionality instance
  final FirebaseAuthFunctionality _auth = FirebaseAuthFunctionality();

  //Setting up the TextEditingControllers
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  //Prevents memory leaks
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        const Center(
            child: Text("Create Account", style: TextStyle(fontSize: 50))),
        //Spacing between the logo and TextFields
        const SizedBox(
          height: 25,
        ),
        TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: "User Name",
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
        //Spacing between the TextFields
        const SizedBox(height: 25),
        TextField(
            controller: _emailController,
            decoration: InputDecoration(
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
        //Spacing between the TextFields
        const SizedBox(height: 25),
        TextField(
            controller: _passwordController,
            decoration: InputDecoration(
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
        //Spacing between the TextFields and login button
        const SizedBox(height: 25),
        ElevatedButton(
            onPressed: () {
              // if (_usernameController.text.isEmpty) {
              //   showToast(message: 'Username must not be empty');
              //   return;
              // }
              //
              // if (_passwordController.text.isEmpty) {
              //   showToast(message: 'Password must not be empty');
              //   return;
              // }
              //
              // if (_passwordController.text.length < 6) {
              //   showToast(message: 'Password must be at least 6 characters long');
              //   return;
              // }
              //
              // if (_emailController.text.isEmpty && !_emailController.text.contains('@') && !_emailController.text.contains('.')) {
              //   return;
              // }

              HouseSyncUser newUser = HouseSyncUser.newUser(
                  _usernameController.text, _emailController.text);
              firebaseAuthFunctionality.registerUser(
                  newUser, _passwordController.text);

              if (newUser.username.isNotEmpty &&
                  newUser.email.contains('@') &&
                  newUser.email.contains('.') &&
                  _passwordController.text.length >= 6) {
                print("User was successfully created");

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              }
            },
            child: Text("Register Now"),
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.blue[800]!),
                foregroundColor:
                    WidgetStateProperty.resolveWith((state) => Colors.white),
                textStyle:
                    WidgetStateProperty.all<TextStyle>(TextStyle(fontSize: 30)),
                minimumSize: WidgetStateProperty.all<Size>(Size(200, 100))))
      ],
    ));
  }

// void _signUp() async {
//   String username = _usernameController.text;
//   String email = _emailController.text;
//   String password = _passwordController.text;
//
//   User? user = await _auth.signUpWithEmailAndPassword(email, password);
//
//   if(user != null) {
//     print("User was successfully created");
//     Navigator.push(context, MaterialPageRoute(
//         builder: (context) => HomePage()
//       )
//     );
//   } else {
//     print("An error occured");
//   }
// }

// Future<void> registerUser(String username, String email, String password) async {
//   UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: email,
//       password: password);
//
//   String? userId = userCredential.user?.uid;
//
//   await FirebaseFirestore.instance.collection('users').doc(userId).set({
//     'username': username,
//     'email': email
//   });
//
//   if(username.isNotEmpty && userCredential.user?.email != null && password.isNotEmpty) {
//         print("User was successfully created");
//         Navigator.push(context, MaterialPageRoute(
//             builder: (context) => HomePage()
//           )
//         );
//       } else {
//         print("An error occured");
//       }
// }
}
