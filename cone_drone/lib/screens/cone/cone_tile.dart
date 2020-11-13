import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:cone_drone/services/bluetooth.dart';

class ConeTile extends StatelessWidget {
  final String name;
  final ConeState state;
  ConeTile({this.name, this.state});

  @override
  Widget build(BuildContext context) {
    // todo: wrap with scoped descendant and inkwell
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: state == ConeState.connected
                ? Colors.green.shade900
                : Colors.redAccent,
            radius: 15.0,
          ),
          title: Text(name ?? 'No Name'),
          subtitle: Text(state.toString()),
        ),
      ),
    );
  }
}
