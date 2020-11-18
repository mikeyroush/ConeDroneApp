import 'package:flutter/material.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/services/auth.dart';
import 'package:cone_drone/constants.dart';

class SettingsForm extends StatefulWidget {
  final BluetoothManager model;
  SettingsForm({this.model});

  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  BluetoothManager _model;

  // form values
  int _currentHeight = 400;

  @override
  void initState() {
    super.initState();
    _model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dead Zone slider
          RichText(
            text: TextSpan(
              text: 'Dead Zone Height\n',
              style: kMenuTextDarkStyle,
              children: [
                TextSpan(
                  text: "$_currentHeight cm",
                  style: kTextFieldDarkStyle,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          Slider(
            value: (_currentHeight).toDouble(),
            min: 0.0,
            max: 400.0,
            divisions: 8,
            onChanged: (val) => setState(() => _currentHeight = val.round()),
          ),
          // Save Settings
          // Todo: Save to database and send message on connection
          FlatButton.icon(
            onPressed: () {
              if (_model.isConnected)
                _model.sendChangeDeadZoneHeight(_currentHeight);
              Navigator.pop(context);
            },
            icon: Icon(Icons.save, color: Colors.white70),
            label: Text('Save Settings', style: kTextFieldStyle),
            color: Colors.blueGrey,
            padding: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          Divider(
            height: 50.0,
            color: Colors.black54,
          ),
          // Log out
          FlatButton.icon(
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
            icon: Icon(Icons.exit_to_app, color: Colors.white70),
            label: Text('Logout', style: kTextFieldStyle),
            color: Colors.blueAccent,
            padding: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ],
      ),
    );
  }
}
