import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/screens/cone/cone_control_panel.dart';

class ConeTile extends StatelessWidget {
  final String name;
  final ConeState state;
  ConeTile({this.name, this.state});

  @override
  Widget build(BuildContext context) {
    void _showConeControlPanel(BluetoothManager model) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 60.0,
                  vertical: 20.0,
                ),
                child: ConeControlPanel(model: model, name: name),
              ),
            ],
          );
        },
      );
    }

    return ScopedModelDescendant<BluetoothManager>(
      builder: (_, child, model) {
        return InkWell(
          onTap: () => _showConeControlPanel(model),
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Card(
              margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: state == ConeState.connected
                      ? Colors.blueAccent
                      : state == ConeState.indicating
                          ? Colors.green.shade800
                          : Colors.redAccent,
                  radius: 15.0,
                ),
                title: Text(name.toUpperCase() ?? 'No Name'),
                subtitle: Text(state.toString()),
              ),
            ),
          ),
        );
      },
    );
  }
}
