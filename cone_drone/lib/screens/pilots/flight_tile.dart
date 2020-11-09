import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cone_drone/models/flight.dart';
import 'package:cone_drone/constants.dart';

class FlightTile extends StatelessWidget {
  final Flight flight;
  FlightTile({this.flight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
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
    );
  }
}
