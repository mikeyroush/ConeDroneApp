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
  bool isCollapsed = false;
  double screenWidth, screenHeight;

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
    if (!verified) return verifyEmail(context);

    // email verified
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return Scaffold(
        backgroundColor: Colors.blueGrey.shade700,
        body: Stack(
          fit: StackFit.expand,
          children: [
            menu(context),
            home(context),
          ],
        ));
  }

  Widget verifyEmail(context) {
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
                  await _auth.currentUser.reload();
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
  }

  Widget menu(context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Home',
                style: kTitleTextStyle.copyWith(color: Colors.white70)),
            SizedBox(height: 16.0),
            Text('Pilots',
                style: kTitleTextStyle.copyWith(color: Colors.white70)),
            SizedBox(height: 16.0),
            Text('Record',
                style: kTitleTextStyle.copyWith(color: Colors.white70)),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget home(context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: isCollapsed ? 0 : 0.2 * screenHeight,
      bottom: isCollapsed ? 0 : 0.2 * screenHeight,
      right: isCollapsed ? 0 : -0.4 * screenWidth,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      child: Material(
        borderRadius: isCollapsed
            ? BorderRadius.circular(0)
            : BorderRadius.circular(10.0),
        elevation: 8.0,
        color: Colors.blueGrey.shade900,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Icon(Icons.menu, color: Colors.white70),
                      onTap: () {
                        setState(() {
                          isCollapsed = !isCollapsed;
                        });
                      },
                    ),
                    Text('HOME', style: kTextFieldStyle),
                    Icon(Icons.settings, color: Colors.white70),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
