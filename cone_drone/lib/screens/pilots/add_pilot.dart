import 'package:cone_drone/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/models/pilot.dart';
import 'package:cone_drone/services/database.dart';
import 'package:cone_drone/constants.dart';

class AddPilotForm extends StatefulWidget {
  @override
  _AddPilotFormState createState() => _AddPilotFormState();
}

class _AddPilotFormState extends State<AddPilotForm> {
  final _formKey = GlobalKey<FormState>();

  // form values
  String _currentName;
  String _currentEmail;
  String _currentPhone;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            'Add new pilot.',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Name',
              hintStyle: TextStyle(color: Colors.black54),
            ),
            validator: (val) => val.isEmpty ? 'Please enter a name.' : null,
            onChanged: (val) => setState(() => _currentName = val),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Email',
              hintStyle: TextStyle(color: Colors.black54),
            ),
            validator: (val) => val.isEmpty ? 'Please enter an email.' : null,
            onChanged: (val) => setState(() => _currentEmail = val),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Phone Number',
              hintStyle: TextStyle(color: Colors.black54),
            ),
            validator: (val) =>
                val.isEmpty ? 'Please enter a phone number.' : null,
            onChanged: (val) => setState(() => _currentPhone = val),
          ),
          RoundedButton(
            title: 'Add',
            backgroundColor: Colors.blueAccent,
            onPress: () async {
              if (_formKey.currentState.validate()) {
                await DatabaseService(instructorID: user.uid)
                    .addPilot(_currentName, _currentEmail, _currentPhone);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
