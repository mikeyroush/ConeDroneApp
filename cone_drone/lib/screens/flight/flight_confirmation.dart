import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:cone_drone/screens/flight/pilot_dropdown.dart';
import 'package:cone_drone/services/database.dart';
import 'package:cone_drone/services/form_validator.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/components/rounded_button.dart';
import 'package:cone_drone/constants.dart';

class FlightConfirmation extends StatefulWidget {
  // form values
  final String currentPilotID;
  final int conesTotal;
  final int conesActivated;
  final int elapsedMilli;
  FlightConfirmation(
      {this.currentPilotID,
      this.conesTotal,
      this.conesActivated,
      this.elapsedMilli});

  @override
  _FlightConfirmationState createState() => _FlightConfirmationState();
}

class _FlightConfirmationState extends State<FlightConfirmation> {
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentPilotID;
  int _conesTotal;
  int _conesActivated;

  @override
  void initState() {
    super.initState();
    _currentPilotID = widget.currentPilotID;
    _conesTotal = widget.conesTotal;
    _conesActivated = widget.conesActivated;
  }

  void updatePilot(String uid) {
    setState(() => _currentPilotID = uid);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);

    return StreamProvider.value(
      value: DatabaseService(instructorID: user.uid).pilots,
      catchError: (_, __) => null,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Review Flight Record',
              style: kMenuTextDarkStyle,
            ),
            SizedBox(height: 12.0),
            PilotDropdown(
              updatePilot: updatePilot,
              pilotID: _currentPilotID,
            ),
            SizedBox(height: 8.0),
            // ***** connected cones *****
            TextFormField(
              initialValue: _conesTotal.toString(),
              style: kTextBold,
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'enter a value.',
                hintStyle: kTextFieldDarkStyle,
                prefix: RichText(
                  textScaleFactor: 1.1,
                  text: TextSpan(
                    text: 'Connected Cones: ',
                    style: kTextFieldDarkStyle,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.singleLineFormatter
              ],
              onChanged: (val) => setState(() => _conesTotal = int.parse(val)),
              validator: FormValidator.validateInteger,
            ),
            SizedBox(height: 8.0),
            // ***** activated cones *****
            TextFormField(
              initialValue: _conesActivated.toString(),
              style: kTextBold,
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'enter a value',
                hintStyle: kTextFieldDarkStyle,
                prefix: RichText(
                  textScaleFactor: 1.1,
                  text: TextSpan(
                    text: 'Activated Cones: ',
                    style: kTextFieldDarkStyle,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.singleLineFormatter
              ],
              onChanged: (val) =>
                  setState(() => _conesActivated = int.parse(val)),
              validator: FormValidator.validateInteger,
            ),
            RoundedButton(
              title: 'Submit',
              backgroundColor: Colors.blueAccent,
              onPress: () async {
                if (_formKey.currentState.validate()) {
                  // send data
                  await DatabaseService().addFlight(
                    _currentPilotID,
                    _conesTotal,
                    _conesActivated,
                    widget.elapsedMilli,
                  );
                  // pop form and reset screen
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
