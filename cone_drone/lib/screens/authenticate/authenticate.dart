import 'package:flutter/material.dart';
import 'package:cone_drone/screens/authenticate/register.dart';
import 'package:cone_drone/screens/authenticate/login.dart';
import 'package:cone_drone/constants.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  kScreenState state = kScreenState.register;

  void toggleScreen() {
    if (state == kScreenState.logIn) {
      setState(() {
        state = kScreenState.register;
      });
    } else {
      setState(() {
        state = kScreenState.logIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return state == kScreenState.logIn
        ? Login(toggleScreen: toggleScreen)
        : Register(toggleScreen: toggleScreen);
  }
}
