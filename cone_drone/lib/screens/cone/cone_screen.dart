import 'package:flutter/material.dart';
import 'package:cone_drone/constants.dart';
import 'package:cone_drone/components/rounded_botton.dart';

enum Status { none, connected, disconnected }

class ConeScreen extends StatefulWidget {
  @override
  _ConeScreenState createState() => _ConeScreenState();
}

class _ConeScreenState extends State<ConeScreen> {
  // temp entries
  List<ConeEntry> entries = [];

  @override
  void initState() {
    super.initState();

    // TODO: dynamically pull cone entries from somewhere
    entries.removeRange(0, entries.length);
    for (var i = 0; i < 50; i++) {
      final entry = ConeEntry(
        name: 'Cone $i',
        status: (i % 2 == 0) ? Status.disconnected : Status.connected,
      );
      setState(() {
        entries.add(entry);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Connected Cones: ${entries.length}', style: kTextFieldStyle),
          SizedBox(height: 8.0),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                color: Colors.blueGrey,
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: entries,
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 65.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: RoundedButton(
                    title: 'Add Cone',
                    backgroundColor: Colors.lightBlueAccent,
                    onPress: () {},
                  ),
                ),
                SizedBox(width: 16.0),
                Flexible(
                  child: RoundedButton(
                    title: 'Remove Cone',
                    backgroundColor: Colors.blueAccent,
                    onPress: () {},
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ConeEntry extends StatelessWidget {
  ConeEntry({@required this.name, @required this.status});

  final String name;
  final Status status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('$name', style: kTextFieldStyle),
        ),
        Expanded(
          child: Text(
              'Status: ${status.toString().substring(status.toString().indexOf('.') + 1)}',
              style: kTextFieldStyle),
        ),
      ],
    );
  }
}
