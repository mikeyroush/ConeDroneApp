import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/screens/home_screen.dart';
import 'package:cone_drone/constants.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/drone.png'),
                    height: 200.0,
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              Text(
                errorMessage != null ? 'Error: $errorMessage' : '',
                style: kTextErrorStyle,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                style: kTextFieldStyle,
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  password = value;
                },
                style: kTextFieldStyle,
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Log In',
                backgroundColor: Colors.lightBlueAccent,
                onPress: () async {
                  setState(() {
                    showSpinner = true;
                    errorMessage = null;
                  });
                  try {
                    final UserCredential userCredential =
                        await _auth.signInWithEmailAndPassword(
                            email: email, password: password);
                    if (UserCredential != null) {
                      Navigator.pushNamed(context, HomeScreen.id);
                    }
                  } on FirebaseAuthException catch (e) {
                    setState(() {
                      errorMessage = e.code;
                    });
                  } catch (e) {
                    setState(() {
                      errorMessage = e;
                    });
                  }
                  setState(() {
                    showSpinner = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
