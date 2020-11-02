import 'package:flutter/material.dart';
import 'package:cone_drone/screens/settings_form.dart';
import 'package:cone_drone/services/auth.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/constants.dart';

enum Status { none, connected, disconnected }

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  AnimationController _controller;
  Animation _scaleAnimation;
  Animation _slideAnimation;
  Animation _menuScaleAnimation;

  bool isCollapsed = false;
  double screenWidth, screenHeight;
  final Duration duration = Duration(milliseconds: 300);

  // temp entries
  List<ConeEntry> entries = [];

  @override
  void initState() {
    super.initState();

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

    // animation
    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.6).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.2, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

  Widget menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: SafeArea(
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
                Divider(
                  height: 8.0,
                  thickness: 1.0,
                  color: Colors.white70,
                ),
                FlatButton.icon(
                  onPressed: () => _auth.signOut(),
                  label: Text('Logout', style: kTextFieldStyle),
                  icon: Icon(Icons.exit_to_app, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget home(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: !isCollapsed ? 0 : 0.4 * screenWidth,
      right: !isCollapsed ? 0 : -0.4 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          borderRadius: !isCollapsed
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
                        child: isCollapsed
                            ? Icon(Icons.arrow_back_ios, color: Colors.white70)
                            : Icon(Icons.menu, color: Colors.white70),
                        onTap: () {
                          setState(() {
                            !isCollapsed
                                ? _controller.forward()
                                : _controller.reverse();
                            isCollapsed = !isCollapsed;
                          });
                        },
                      ),
                      Text('Dashboard', style: kTextFieldStyle),
                      SizedBox(),
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
