import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/screens/home_screen.dart';
import 'package:cone_drone/constants.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
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
                // check for registration error
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
                  title: 'Register',
                  backgroundColor: Colors.blueAccent,
                  onPress: () async {
                    setState(() {
                      showSpinner = true;
                      errorMessage = null;
                    });
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);
                      if (newUser != null) {
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
      ),
    );
  }
}
