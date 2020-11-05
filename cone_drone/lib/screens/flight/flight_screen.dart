import 'dart:async';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cone_drone/services/auth.dart';
import 'package:cone_drone/services/database.dart';
import 'package:cone_drone/models/pilot.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/constants.dart';

class FlightScreen extends StatefulWidget {
  @override
  _FlightScreenState createState() => _FlightScreenState();
}

class _FlightScreenState extends State<FlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final Duration refreshRate = Duration(milliseconds: 100);
  Stopwatch _stopwatch = Stopwatch();
  String timeElapsed = "00:00.0";
  Orientation screenOrientation;

  // todo: remove temp array
  final List<String> pilots = ['pilot 1', 'pilot 2', 'pilot 3'];

  void updateStopwatch() {
    Timer(refreshRate, () {
      if (_stopwatch.isRunning) {
        updateStopwatch();
        setState(() {
          timeElapsed = (_stopwatch.elapsed.inMinutes % 60)
                  .toString()
                  .padLeft(2, '0') +
              ":" +
              (_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0') +
              "." +
              ((_stopwatch.elapsed.inMilliseconds % 1000) / 100)
                  .floor()
                  .toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenOrientation = MediaQuery.of(context).orientation;

    return Expanded(
      child: Column(
        children: [
          Expanded(
            flex: (screenOrientation == Orientation.portrait) ? 3 : 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        timeElapsed,
                        style: kTimerTextStyle.copyWith(color: Colors.white70),
                      ),
                    ),
                  ),
                  // SizedBox(height: 8.0),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: RoundedButton(
                            title: 'Start',
                            backgroundColor: Colors.lightBlueAccent,
                            onPress: () {
                              _stopwatch.start();
                              updateStopwatch();
                            },
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Flexible(
                          child: RoundedButton(
                            title: _stopwatch.isRunning ? 'Stop' : 'Reset',
                            backgroundColor: Colors.redAccent,
                            onPress: () {
                              _stopwatch.isRunning
                                  ? setState(() => _stopwatch.stop())
                                  : setState(() {
                                      _stopwatch.reset();
                                      timeElapsed = "00:00.0";
                                    });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            flex: (screenOrientation == Orientation.portrait) ? 5 : 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField(
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Pilot',
                                hintStyle: TextStyle(color: Colors.black54)),
                            items: pilots.map((pilot) {
                              return DropdownMenuItem(
                                value: pilot,
                                child: Text(pilot),
                              );
                            }).toList(),
                            onChanged: (_) {},
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Total number of cones',
                                hintStyle: TextStyle(color: Colors.black54)),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            decoration: kTextFieldDecoration.copyWith(
                                hintText: 'Number of activated cones',
                                hintStyle: TextStyle(color: Colors.black54)),
                          ),
                          RoundedButton(
                            title: 'Submit',
                            backgroundColor: Colors.blueAccent,
                            onPress: () {},
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
