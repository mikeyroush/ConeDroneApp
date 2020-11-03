import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/screens/authenticate/authenticate.dart';
import 'package:cone_drone/screens/home/verify_email.dart';
import 'package:cone_drone/screens/menu_layout.dart';
import 'package:cone_drone/screens/error_screen.dart';
import 'package:cone_drone/screens/loading_screen.dart';
import 'package:cone_drone/constants.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  kState _state = kState.loading;

  // initialize Firebase
  void initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _state = kState.initialized;
      });
    } catch (e) {
      setState(() {
        _state = kState.error;
      });
    }
  }

  @override
  void initState() {
    initializeFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return loading, error, home or authenticate screen
    if (_state == kState.error)
      return ErrorScreen();
    else if (_state == kState.loading)
      return LoadingScreen();
    else {
      final user = Provider.of<MyUser>(context);
      return user == null
          ? Authenticate()
          : !user.isVerified ? Verify() : HomeScreen();
    }
  }
}
