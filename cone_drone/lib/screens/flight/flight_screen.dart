import 'dart:async';
import 'package:cone_drone/screens/flight/flight_form.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/constants.dart';

class FlightScreen extends StatefulWidget {
  @override
  _FlightScreenState createState() => _FlightScreenState();
}

class _FlightScreenState extends State<FlightScreen> {
  final Duration refreshRate = Duration(milliseconds: 100);
  Stopwatch _stopwatch = Stopwatch();
  String timeElapsed = "00:00.0";
  Orientation screenOrientation;

  void updateStopwatch() {
    Timer(refreshRate, () {
      if (_stopwatch.isRunning) {
        updateStopwatch();
        setState(
            () => timeElapsed = kFormatMilli(_stopwatch.elapsedMilliseconds));
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

    return ScopedModelDescendant<BluetoothManager>(
      builder: (_, child, model) {
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
                            style:
                                kTimerTextStyle.copyWith(color: Colors.white70),
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
                    child: FlightSubmissionForm(model: model),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
