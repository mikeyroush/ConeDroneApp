import 'package:cone_drone/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/models/pilot.dart';
import 'package:cone_drone/services/database.dart';
import 'package:cone_drone/constants.dart';

class UpdatePilotForm extends StatefulWidget {
  final Pilot pilot;
  UpdatePilotForm({this.pilot});

  @override
  _UpdatePilotFormState createState() => _UpdatePilotFormState();
}

class _UpdatePilotFormState extends State<UpdatePilotForm> {
  final _formKey = GlobalKey<FormState>();

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
            validator: (val) => val.isEmpty ? 'Please enter a name.' : null,
            onChanged: (val) => setState(() => _currentName = val),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            initialValue: _currentEmail ?? widget.pilot.email,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Email',
              hintStyle: TextStyle(color: Colors.black54),
            ),
            validator: (val) => val.isEmpty ? 'Please enter an email.' : null,
            onChanged: (val) => setState(() => _currentEmail = val),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            initialValue: _currentPhone ?? widget.pilot.phone,
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Phone Number',
              hintStyle: TextStyle(color: Colors.black54),
            ),
            validator: (val) =>
                val.isEmpty ? 'Please enter a phone number.' : null,
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
        ],
      ),
    );
  }
}
