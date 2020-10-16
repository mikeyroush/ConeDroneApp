import 'package:cone_drone/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cone_drone/constants.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;
enum Status { none, connected, disconnected }
enum Collapsed { none, left, right }

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  bool verified = false;
  Collapsed collapsed = Collapsed.none;
  double screenWidth, screenHeight;

  // temp entries
  List<ConeEntry> entries = [];

  @override
  void initState() {
    super.initState();
    getCurrentUser();

    // TODO: dynamically pull cone entries from somewhere
    entries.removeRange(0, entries.length);
    for (var i = 0; i < 50; i++) {
      final entry = ConeEntry(
        name: 'Cone $i',
        status: (i % 2 == 0) ? Status.disconnected : Status.connected,
      );
      setState(() {
        entries.add(entry);
      });
    }
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
      ),
    );
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
      child: Row(
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dashboard, color: Colors.white70),
                      SizedBox(width: 8.0),
                      Text('Dashboard', style: kMenuTextStyle),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.white70),
                      SizedBox(width: 8.0),
                      Text('Pilots', style: kMenuTextStyle),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Icon(Icons.adjust, color: Colors.white70),
                      SizedBox(width: 8.0),
                      Text('Record', style: kMenuTextStyle),
                    ],
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    child: Row(
                      children: [
                        Icon(Icons.power_settings_new, color: Colors.white70),
                        SizedBox(width: 8.0),
                        Text('Logout', style: kMenuTextStyle),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _auth.signOut();
                      });
                      Navigator.popUntil(
                          context, ModalRoute.withName(WelcomeScreen.id));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget home(context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      top: (collapsed == Collapsed.none) ? 0 : 0.2 * screenHeight,
      bottom: (collapsed == Collapsed.none) ? 0 : 0.2 * screenHeight,
      right: (collapsed == Collapsed.none)
          ? 0
          : (collapsed == Collapsed.right)
              ? -0.3 * screenWidth
              : 0.5 * screenWidth,
      left: (collapsed == Collapsed.none)
          ? 0
          : (collapsed == Collapsed.right)
              ? 0.5 * screenWidth
              : -0.3 * screenWidth,
      child: Material(
        borderRadius: (collapsed == Collapsed.none)
            ? BorderRadius.circular(0)
            : BorderRadius.circular(10.0),
        elevation: 8.0,
        color: Colors.blueGrey.shade900,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
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
                          if (collapsed != Collapsed.none)
                            collapsed = Collapsed.none;
                          else
                            collapsed = Collapsed.right;
                        });
                      },
                    ),
                    Text('Dashboard', style: kTextFieldStyle),
                    InkWell(
                      child: Icon(Icons.settings, color: Colors.white70),
                      onTap: () {
                        setState(() {
                          if (collapsed != Collapsed.none)
                            collapsed = Collapsed.none;
                          else
                            collapsed = Collapsed.left;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Text('Connected Cones: ${entries.length}',
                    style: kTextFieldStyle),
                SizedBox(height: 8.0),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      color: Colors.blueGrey,
                      child: ListView(
                        padding: const EdgeInsets.all(8.0),
                        children: entries,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 65.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: RoundedButton(
                          title: 'Add Cone',
                          backgroundColor: Colors.lightBlueAccent,
                          onPress: () {},
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Flexible(
                        child: RoundedButton(
                          title: 'Remove Cone',
                          backgroundColor: Colors.blueAccent,
                          onPress: () {},
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConeEntry extends StatelessWidget {
  ConeEntry({@required this.name, @required this.status});

  final String name;
  final Status status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('$name', style: kTextFieldStyle),
        ),
        Expanded(
          child: Text(
              'Status: ${status.toString().substring(status.toString().indexOf('.') + 1)}',
              style: kTextFieldStyle),
        ),
      ],
    );
  }
}
