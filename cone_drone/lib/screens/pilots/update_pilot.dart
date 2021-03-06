import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cone_drone/components/rounded_button.dart';
import 'package:cone_drone/models/pilot.dart';
import 'package:cone_drone/models/flight.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/services/database.dart';
import 'package:cone_drone/services/form_validator.dart';
import 'package:cone_drone/screens/pilots/flight_list.dart';
import 'package:cone_drone/constants.dart';

class UpdatePilotForm extends StatefulWidget {
  final Pilot pilot;
  UpdatePilotForm({this.pilot});

  @override
  _UpdatePilotFormState createState() => _UpdatePilotFormState();
}

class _UpdatePilotFormState extends State<UpdatePilotForm> {
  final _formKey = GlobalKey<FormState>();
  final phoneFormatter = FormValidator().phoneFormatter;

  // form values
  String _currentName;
  String _currentEmail;
  String _currentPhone;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            'Update pilot.',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            initialValue: _currentName ?? widget.pilot.name,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Name',
              hintStyle: TextStyle(color: Colors.black54),
            ),
            validator: FormValidator.validateName,
            keyboardType: TextInputType.text,
            onChanged: (val) => setState(() => _currentName = val),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            initialValue: _currentEmail ?? widget.pilot.email,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Email',
              hintStyle: TextStyle(color: Colors.black54),
            ),
            validator: FormValidator.validateEmail,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => setState(() => _currentEmail = val),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            initialValue: _currentPhone ?? widget.pilot.phone,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Phone Number',
              hintStyle: TextStyle(color: Colors.black54),
            ),
            validator: FormValidator.validatePhone,
            keyboardType: TextInputType.phone,
            inputFormatters: [phoneFormatter],
            onChanged: (val) => setState(() => _currentPhone = val),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: RoundedButton(
                  title: 'Update',
                  backgroundColor: Colors.blueAccent,
                  onPress: () async {
                    if (_formKey.currentState.validate()) {
                      await DatabaseService(pilotID: widget.pilot.uid)
                          .updatePilotData(
                              _currentName ?? widget.pilot.name,
                              _currentEmail ?? widget.pilot.email,
                              _currentPhone ?? widget.pilot.phone,
                              widget.pilot.instructorID);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              SizedBox(width: 10.0),
              Flexible(
                child: RoundedButton(
                  title: 'Delete',
                  backgroundColor: Colors.redAccent,
                  onPress: () async {
                    await DatabaseService(pilotID: widget.pilot.uid)
                        .deletePilot();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.black54)),
              FlatButton(
                child: Text(
                  'View Records',
                  style: kTextFieldDarkStyle,
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return StreamProvider<List<Flight>>.value(
                      value: DatabaseService(pilotID: widget.pilot.uid).flights,
                      catchError: (_, __) => null,
                      child: FlightList(),
                    );
                  },
                )),
              ),
              Expanded(child: Divider(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}
