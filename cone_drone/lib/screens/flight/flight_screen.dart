import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cone_drone/screens/flight/flight_form.dart';
import 'package:cone_drone/screens/flight/flight_stopwatch.dart';
import 'package:cone_drone/services/bluetooth.dart';

class FlightScreen extends StatefulWidget {
  @override
  _FlightScreenState createState() => _FlightScreenState();
}

class _FlightScreenState extends State<FlightScreen> {
  Orientation screenOrientation;

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
                  child: FlightStopwatch(model: model),
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
                    child: FlightSubmissionForm(),
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
