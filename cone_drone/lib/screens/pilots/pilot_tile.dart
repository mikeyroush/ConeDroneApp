import 'package:flutter/material.dart';
import 'package:cone_drone/models/pilot.dart';
import 'package:cone_drone/screens/pilots/update_pilot.dart';

class PilotTile extends StatelessWidget {
  final Pilot pilot;
  PilotTile({this.pilot});

  @override
  Widget build(BuildContext context) {
    void _showUpdatePilotPanel() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 60.0,
              vertical: 20.0,
            ),
            child: UpdatePilotForm(pilot: pilot),
          );
        },
      );
    }

    return InkWell(
      onTap: () => _showUpdatePilotPanel(),
      child: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Card(
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            leading: Icon(Icons.person, color: Colors.black54),
            title: Text(pilot.name),
            subtitle: Text(pilot.email),
          ),
        ),
      ),
    );
  }
}
