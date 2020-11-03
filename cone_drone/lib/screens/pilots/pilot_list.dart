import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cone_drone/models/pilot.dart';
import 'package:cone_drone/screens/pilots/pilot_tile.dart';

class PilotList extends StatefulWidget {
  @override
  _PilotListState createState() => _PilotListState();
}

class _PilotListState extends State<PilotList> {
  @override
  Widget build(BuildContext context) {
    final pilots = Provider.of<List<Pilot>>(context) ?? [];

    return ListView.builder(
      itemCount: pilots.length,
      itemBuilder: (context, index) {
        return PilotTile(pilot: pilots[index]);
      },
    );
  }
}
