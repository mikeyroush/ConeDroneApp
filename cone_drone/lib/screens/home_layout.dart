import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cone_drone/screens/settings_form.dart';
import 'package:cone_drone/screens/cone/cone_screen.dart';
import 'package:cone_drone/screens/pilots/pilot_screen.dart';
import 'package:cone_drone/screens/flight/flight_screen.dart';
import 'package:cone_drone/screens/disable_bluetooth.dart';
import 'package:cone_drone/services/auth.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/components/bottom_sheet_template.dart';
import 'package:cone_drone/constants.dart';

class HomeLayout extends StatefulWidget {
  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final BluetoothManager _bluetoothManager = BluetoothManager();
  AnimationController _controller;
  Animation _scaleAnimation;
  Animation _slideAnimation;
  Animation _menuScaleAnimation;
  kScreenState _state = kScreenState.cone;

  bool isCollapsed = false;
  double screenWidth, screenHeight;
  final Duration duration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

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
      body: ScopedModel(
        model: _bluetoothManager,
        child: Stack(
          fit: StackFit.expand,
          children: [
            menu(context),
            screen(context),
            DisabledBluetooth(),
          ],
        ),
      ),
    );
  }

  Widget menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FlatButton.icon(
                        onPressed: () => setState(() {
                          toggleMenu();
                          _state = kScreenState.cone;
                        }),
                        icon: Icon(Icons.dashboard, color: Colors.white70),
                        label: Text('Dashboard', style: kMenuTextStyle),
                      ),
                      FlatButton.icon(
                        onPressed: () => setState(() {
                          toggleMenu();
                          _state = kScreenState.pilot;
                        }),
                        icon: Icon(Icons.person, color: Colors.white70),
                        label: Text('Pilots', style: kMenuTextStyle),
                      ),
                      FlatButton.icon(
                        onPressed: () => setState(() {
                          toggleMenu();
                          _state = kScreenState.record;
                        }),
                        icon: Icon(Icons.adjust, color: Colors.white70),
                        label: Text('Record', style: kMenuTextStyle),
                      ),
                      SizedBox(height: 16.0),
                      Divider(
                        height: 8.0,
                        thickness: 1.0,
                        color: Colors.white70.withOpacity(0.4),
                      ),
                      FlatButton.icon(
                        onPressed: () => bottomSheetTemplate(
                          context: context,
                          child: SettingsForm(model: _bluetoothManager),
                        ),
                        icon: Icon(Icons.exit_to_app, color: Colors.white70),
                        label: Text('Settings', style: kTextFieldStyle),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(flex: 2, child: Container()),
            ],
          ),
        ),
      ),
    );
  }

  Widget screen(context) {
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        child: SizedBox(
                          width: 30.0,
                          height: 30.0,
                          child: isCollapsed
                              ? Icon(Icons.arrow_back_ios,
                                  color: Colors.white70)
                              : Icon(Icons.menu, color: Colors.white70),
                        ),
                        onTap: () {
                          setState(() {
                            toggleMenu();
                          });
                        },
                      ),
                      Text('Cone Drone',
                          style: kTextFieldStyle.copyWith(fontSize: 18.0)),
                      SizedBox(),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  (_state == kScreenState.cone)
                      ? ConeScreen()
                      : (_state == kScreenState.pilot)
                          ? PilotScreen()
                          : FlightScreen()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void toggleMenu() {
    !isCollapsed ? _controller.forward() : _controller.reverse();
    isCollapsed = !isCollapsed;
  }
}
