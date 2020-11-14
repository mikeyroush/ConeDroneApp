import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/constants.dart';

class ConeControlPanel extends StatelessWidget {
  final BluetoothManager model;
  final String name;
  ConeControlPanel({this.model, this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Align(
          alignment: Alignment.center,
          child: Text(
            name.toUpperCase(),
            style: kMenuTextStyle.copyWith(color: Colors.black54),
          ),
        ),
        SizedBox(height: 16.0),
        // reset cone button
        FlatButton.icon(
          onPressed: () => model.sendReset(name),
          icon: Icon(
            Icons.refresh,
            color: Colors.white70,
          ),
          label: Text(
            'Reset Cone',
            style: kMenuTextStyle,
          ),
          color: Colors.blueAccent,
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        SizedBox(height: 8.0),
        // do indication button
        FlatButton.icon(
          onPressed: () => model.sendDoIndicate(name),
          icon: Icon(
            Icons.lightbulb_outline,
            color: Colors.white70,
          ),
          label: Text(
            'Indicate',
            style: kMenuTextStyle,
          ),
          color: Colors.lightBlueAccent,
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ],
    );
  }
}
