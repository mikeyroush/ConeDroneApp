import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/services/form_validator.dart';
import 'package:cone_drone/screens/flight/pilot_dropdown.dart';
import 'package:cone_drone/services/database.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/constants.dart';

class FlightSubmissionForm extends StatefulWidget {
  final BluetoothManager model;
  FlightSubmissionForm({this.model});

  @override
  _FlightSubmissionFormState createState() => _FlightSubmissionFormState();
}

class _FlightSubmissionFormState extends State<FlightSubmissionForm> {
  final _formKey = GlobalKey<FormState>();
  String _currentPilotID;

  void updatePilot(String uid) {
    setState(() => _currentPilotID = uid);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);

    return StreamProvider.value(
      value: DatabaseService(instructorID: user.uid).pilots,
      catchError: (_, __) => null,
      child: ListView(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                PilotDropdown(updatePilot: updatePilot),
                SizedBox(height: 8.0),
                // ***** connected cones *****
                TextFormField(
                  readOnly: true,
                  initialValue: ' ',
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: '',
                    prefix: RichText(
                      textScaleFactor: 1.1,
                      text: TextSpan(
                        text: 'Connected Cones: ',
                        style: kTextFieldDarkStyle,
                        children: [
                          TextSpan(
                              text: '${widget.model.numConnected}',
                              style: kTextBold),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                // ***** activated cones *****
                TextFormField(
                  readOnly: true,
                  initialValue: ' ',
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: '',
                    prefix: RichText(
                      textScaleFactor: 1.1,
                      text: TextSpan(
                        text: 'Activated Cones: ',
                        style: kTextFieldDarkStyle,
                        children: [
                          TextSpan(
                              text: '${widget.model.numActivated}',
                              style: kTextBold),
                        ],
                      ),
                    ),
                  ),
                ),
                RoundedButton(
                  title: 'Review',
                  backgroundColor: Colors.blueAccent,
                  onPress: () async {
                    if (_formKey.currentState.validate() &&
                        !widget.model.stopwatch.isRunning) {
                      // send data
                      await DatabaseService().addFlight(
                          _currentPilotID,
                          widget.model.numConnected,
                          widget.model.numActivated,
                          widget.model.stopwatch.elapsedMilliseconds);
                      // reset form and stopwatch
                      _formKey.currentState.reset();
                      setState(() {
                        widget.model.stopwatch.reset();
                        // timeElapsed = "00:00.0";
                      });
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
