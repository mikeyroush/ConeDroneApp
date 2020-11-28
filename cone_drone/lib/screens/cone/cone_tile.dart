import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/screens/cone/cone_control_panel.dart';
import 'package:cone_drone/components/bottom_sheet_template.dart';

class ConeTile extends StatelessWidget {
  final String name;
  final ConeState state;
  ConeTile({this.name, this.state});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BluetoothManager>(
      builder: (_, child, model) {
        return InkWell(
          onTap: () => bottomSheetTemplate(
            context: context,
            child: ConeControlPanel(
              model: model,
              name: name,
            ),
          ),
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
