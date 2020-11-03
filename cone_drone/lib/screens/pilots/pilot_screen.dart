import 'package:flutter/material.dart';
import 'package:cone_drone/constants.dart';

class PilotScreen extends StatefulWidget {
  @override
  _PilotScreenState createState() => _PilotScreenState();
}

class _PilotScreenState extends State<PilotScreen> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Text('Pilots',
            style: kTitleTextStyle.copyWith(color: Colors.white70)),
      ),
    );
  }
}
