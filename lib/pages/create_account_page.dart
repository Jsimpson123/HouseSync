import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/user_model.dart';
import 'package:shared_accommodation_management_app/user_auth/firebase_auth_functionality.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() {
    return _CreateAccountPageState();
  }
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  FirebaseAuthFunctionality firebaseAuthFunctionality = FirebaseAuthFunctionality();

  //Setting up the TextEditingControllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //Prevents memory leaks
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //For the password text
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    //Theme is always light as user hasn't had the ability to change it yet
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        resizeToAvoidBottomInset: false, //Stop overflow when keyboard opens
        body: createRegisterPageBody(),
      ),
    );
  }

  SingleChildScrollView createRegisterPageBody() {
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

        const Center(child: Text("Create Account", style: TextStyle(fontSize: 50))),
        //Spacing between the logo and TextFields
        const SizedBox(
          height: 25,
        ),
        SizedBox(
          width: isMobile ? 300 : 400,
          child: TextField(
              key: const Key("registerUsernameField"),
              controller: _usernameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_box_rounded),
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
        ),
        //Spacing between the TextFields
        const SizedBox(height: 25),
        SizedBox(
          width: isMobile ? 300 : 400,
          child: TextField(
              key: const Key("registerEmailField"),
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_rounded),
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
        ),
        //Spacing between the TextFields
        const SizedBox(height: 25),
        SizedBox(
          width: isMobile ? 300 : 400,
          child: TextField(
              key: const Key("registerPasswordField"),
              controller: _passwordController,
              obscureText: _isHidden,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.password_rounded),
                hintText: "Password",
                filled: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.green, width: 2.0)),
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
                          )),
              )),
        ),
        //Spacing between the TextFields and login button
        const SizedBox(height: 25),
        ElevatedButton(
            key: const Key("registerNowButton"),
            onPressed: () async {
              HouseSyncUser newUser =
                  HouseSyncUser.newUser(_usernameController.text, _emailController.text);
              await firebaseAuthFunctionality.registerUser(
                  newUser, _passwordController.text, context);
            },
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue[800]!),
                foregroundColor: WidgetStateProperty.resolveWith((state) => Colors.white),
                textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 30)),
                minimumSize: WidgetStateProperty.all<Size>(const Size(200, 100))),
            child: const Text("Register Now"))
      ],
    ));
  }
}
