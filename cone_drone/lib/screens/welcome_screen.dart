import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cone_drone/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cone_drone/screens/welcome_screen.dart';
import 'package:cone_drone/screens/login_screen.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/constants.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  bool _initialized = false;
  bool _error = false;

  // function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
        print('initialized: $_initialized');
      });
    } catch (e) {
      setState(() {
        _error = true;
        print('Error: $_error');
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();

    controller = AnimationController(
        duration: Duration(seconds: 1, milliseconds: 200), vsync: this);
    animation = ColorTween(begin: Colors.white, end: Colors.blueGrey.shade900)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return errorScreen();
    } else if (!_initialized) {
      return loadingScreen();
    }

    // show welcome screen
    return MaterialApp(
      home: Scaffold(
        backgroundColor: animation.value,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          child: Image.asset('images/drone.png'),
                          height: 60.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 7,
                      child: TypewriterAnimatedTextKit(
                        speed: Duration(milliseconds: 300),
                        totalRepeatCount: 1,
                        text: ['Drone Cone'],
                        textStyle: kTitleTextStyle,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 48.0,
                ),
                RoundedButton(
                  title: 'Log In',
                  backgroundColor: Colors.lightBlueAccent,
                  onPress: () {
                    Navigator.pushNamed(context, LoginScreen.id);
                  },
                ),
                RoundedButton(
                  title: 'Register',
                  backgroundColor: Colors.blueAccent,
                  onPress: () {
                    Navigator.pushNamed(context, RegistrationScreen.id);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget errorScreen() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text("Error: Couldn't initialize firebase app"),
      ),
    ),
  );
}

Widget loadingScreen() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}
