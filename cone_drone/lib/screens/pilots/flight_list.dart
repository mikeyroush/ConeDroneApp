import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cone_drone/models/flight.dart';
import 'package:cone_drone/screens/pilots/flight_tile.dart';
import 'package:cone_drone/constants.dart';

class FlightList extends StatefulWidget {
  @override
  _FlightListState createState() => _FlightListState();
}

class _FlightListState extends State<FlightList> {
  @override
  Widget build(BuildContext context) {
    final flights = Provider.of<List<Flight>>(context) ?? [];

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade600,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white70,
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  Text(
                    'Flight Records',
                    style: kTextFieldStyle,
                  ),
                  SizedBox()
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: flights.length,
                itemBuilder: (context, index) {
                  return FlightTile(flight: flights[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
