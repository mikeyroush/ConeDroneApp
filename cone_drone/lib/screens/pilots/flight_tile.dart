import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cone_drone/models/flight.dart';
import 'package:cone_drone/services/database.dart';
import 'package:cone_drone/constants.dart';

class FlightTile extends StatelessWidget {
  final Flight flight;
  FlightTile({this.flight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Dismissible(
        key: Key(flight.uid),
        onDismissed: (direction) =>
            DatabaseService(flightID: flight.uid).deleteFlight(),
        background: Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.only(right: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            color: Colors.redAccent,
          ),
          child: Icon(Icons.delete, color: Colors.white70),
        ),
        child: Card(
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            leading: Column(
              children: [
                Text('${flight.activatedCones}'),
                SizedBox(width: 16.0, child: Divider(color: Colors.black54)),
                Text('${flight.totalCones}'),
              ],
            ),
            // Todo: update elapsed time label
            title: Text('Time: ${kFormatMilli(flight.timeElapsedMilli)}'),
            subtitle: Text(
                '${DateFormat.yMMMd().format(flight.timeStamp)} at ${DateFormat.Hm().format(flight.timeStamp)}'),
          ),
        ),
      ),
    );
  }
}
