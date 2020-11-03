import 'package:flutter/material.dart';
import 'package:cone_drone/models/pilot.dart';

class PilotTile extends StatelessWidget {
  final Pilot pilot;
  PilotTile({this.pilot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: Icon(Icons.person, color: Colors.black54),
          title: Text(pilot.name),
          subtitle: Text(pilot.email),
        ),
      ),
    );
  }
}
