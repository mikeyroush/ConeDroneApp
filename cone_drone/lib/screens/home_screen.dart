import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cone_drone/constants.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  bool verified = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final User user = _auth.currentUser;
      if (user != null) {
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        } else {
          loggedInUser = user;
          setState(() {
            verified = true;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!verified)
      return Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Check your email for a verification link.',
                  style: kTitleTextStyle.copyWith(color: Colors.white70),
                ),
                SizedBox(height: 10.0),
                RoundedButton(
                  title: 'Verify',
                  backgroundColor: Colors.blueAccent,
                  onPress: () async {
                    _auth.currentUser.reload();
                    setState(() {
                      verified = _auth.currentUser.emailVerified;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      );

    // else verified is true
    return Container(
      child:
          Scaffold(body: Center(child: Text('HOME', style: kTitleTextStyle))),
    );
  }
}
