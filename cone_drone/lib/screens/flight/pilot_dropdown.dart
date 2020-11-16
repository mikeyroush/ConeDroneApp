import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cone_drone/models/pilot.dart';
import 'package:cone_drone/services/form_validator.dart';
import 'package:cone_drone/constants.dart';

class PilotDropdown extends StatefulWidget {
  final Function updatePilot;
  final String pilotID;
  PilotDropdown({this.updatePilot, this.pilotID});

  @override
  _PilotDropdownState createState() => _PilotDropdownState();
}

class _PilotDropdownState extends State<PilotDropdown> {
  @override
  Widget build(BuildContext context) {
    final pilots = Provider.of<List<Pilot>>(context) ?? [];

    return DropdownButtonFormField(
      decoration: kTextFieldDecoration.copyWith(
          hintText: 'Pilot', hintStyle: TextStyle(color: Colors.black54)),
      items: pilots.map((pilot) {
        return DropdownMenuItem(
          value: pilot.uid,
          child: Text(pilot.name),
        );
      }).toList(),
      value: widget.pilotID,
      validator: FormValidator.validateDropdown,
      onChanged: widget.updatePilot,
    );
  }
}
