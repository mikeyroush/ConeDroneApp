import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/components/rounded_button.dart';
import 'package:cone_drone/constants.dart';

class FlightStopwatch extends StatefulWidget {
  final BluetoothManager model;
  FlightStopwatch({this.model});

  @override
  _FlightStopwatchState createState() => _FlightStopwatchState();
}

class _FlightStopwatchState extends State<FlightStopwatch> {
  BluetoothManager _model;
  final Duration refreshRate = Duration(milliseconds: 100);
  String timeElapsed = "00:00.0";

  @override
  void initState() {
    super.initState();
    _model = widget.model;
    updateStopwatch();
  }

  void updateStopwatch() {
    Timer(refreshRate, () {
      if (_model.stopwatch.isRunning && mounted) {
        updateStopwatch();
        setState(() =>
            timeElapsed = kFormatMilli(_model.stopwatch.elapsedMilliseconds));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    _model.stopwatch.start();
                    updateStopwatch();
                  },
                ),
              ),
              SizedBox(width: 8.0),
              Flexible(
                child: RoundedButton(
                  title: _model.stopwatch.isRunning ? 'Stop' : 'Reset',
                  backgroundColor: Colors.redAccent,
                  onPress: () {
                    _model.stopwatch.isRunning
                        ? setState(() => _model.stopwatch.stop())
                        : setState(() {
                            _model.stopwatch.reset();
                            timeElapsed = "00:00.0";
                          });
                    _model.sendResetAll();
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
