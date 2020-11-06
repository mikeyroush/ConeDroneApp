import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cone_drone/components/rounded_botton.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/models/pilot.dart';
import 'package:cone_drone/services/form_validator.dart';
import 'package:cone_drone/services/database.dart';
import 'package:cone_drone/constants.dart';

class AddPilotForm extends StatefulWidget {
  @override
  _AddPilotFormState createState() => _AddPilotFormState();
}

class _AddPilotFormState extends State<AddPilotForm> {
  final _formKey = GlobalKey<FormState>();
  final phoneFormatter = MaskTextInputFormatter(
      mask: '+# (###) ###-####', filter: {"#": RegExp(r'[0-9]')});

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
            validator: FormValidator.validateName,
            keyboardType: TextInputType.text,
            onChanged: (val) => setState(() => _currentName = val),
          ),
          SizedBox(height: 20.0),
          TextFormField(
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
            decoration: kTextFieldDecoration.copyWith(
              hintText: 'Phone Number',
              hintStyle: TextStyle(color: Colors.black54),
            ),
            validator: FormValidator.validatePhone,
            keyboardType: TextInputType.phone,
            inputFormatters: [phoneFormatter],
            onChanged: (val) => setState(() => _currentPhone = val),
          ),
          RoundedButton(
            title: 'Add',
            backgroundColor: Colors.blueAccent,
            onPress: () async {
              print('pressed: $_currentPhone');
              if (_formKey.currentState.validate()) {
                print('made it: $_currentPhone');
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
