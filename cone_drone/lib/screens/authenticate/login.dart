import 'package:flutter/material.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/screens/loading_screen.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/services/auth.dart';
import 'package:cone_drone/constants.dart';

class Login extends StatefulWidget {
  final Function toggleScreen;
  Login({this.toggleScreen});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  Orientation screenOrientation;
  bool _loading = false;
  String email = '';
  String pass = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    screenOrientation = MediaQuery.of(context).orientation;
    return _loading
        ? LoadingScreen()
        : Scaffold(
            backgroundColor: Colors.blueGrey.shade900,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
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
                        height: screenOrientation == Orientation.portrait
                            ? 48.0
                            : 8.0,
                      ),
                      TextFormField(
                        validator: AuthService.validateEmail,
                        style: kTextFieldStyle,
                        decoration:
                            kTextFieldDecoration.copyWith(hintText: 'Email'),
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        obscureText: true,
                        validator: AuthService.validatePassword,
                        style: kTextFieldStyle,
                        decoration:
                            kTextFieldDecoration.copyWith(hintText: 'Password'),
                        onChanged: (value) {
                          setState(() {
                            pass = value;
                          });
                        },
                      ),
                      RoundedButton(
                        title: 'Sign In',
                        backgroundColor: Colors.lightBlueAccent,
                        onPress: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() => _loading = true);
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(email, pass);
                            if (result.runtimeType != MyUser) {
                              setState(() {
                                error = result;
                                _loading = false;
                              });
                            }
                          }
                          // dynamic result = await _auth.signInAnonymously();
                          // result == null
                          //     ? print('error signing in')
                          //     : print('signed in\n${result.uid}');
                        },
                      ),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white70)),
                          FlatButton(
                            onPressed: () => widget.toggleScreen(),
                            child: Text(
                              "Don't have an account?",
                              style: kTextFieldStyle,
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white70)),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Text(error, style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
