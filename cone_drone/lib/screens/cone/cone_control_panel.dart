import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/constants.dart';

class ConeControlPanel extends StatefulWidget {
  final BluetoothManager model;
  final String name;
  ConeControlPanel({this.model, this.name});

  @override
  _ConeControlPanelState createState() => _ConeControlPanelState();
}

class _ConeControlPanelState extends State<ConeControlPanel> {
  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  void checkConnection() {
    Timer(Duration(seconds: 1), () {
      if (widget.model.isConnected)
        checkConnection();
      else if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Align(
          alignment: Alignment.center,
          child: Text(
            widget.name.toUpperCase(),
            style: kMenuTextStyle.copyWith(color: Colors.black54),
          ),
        ),
        SizedBox(height: 16.0),
        // reset cone button
        FlatButton.icon(
          onPressed: () => widget.model.sendReset(widget.name),
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
          onPressed: () => widget.model.sendDoIndicate(widget.name),
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
        SizedBox(height: 8.0),
        // disconnect button
        FlatButton.icon(
          onPressed: () => widget.model.sendDisconnect(widget.name),
          icon: Icon(
            Icons.power_settings_new,
            color: Colors.white70,
          ),
          label: Text(
            'Power Off',
            style: kMenuTextStyle,
          ),
          color: Colors.redAccent,
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ],
    );
  }
}
