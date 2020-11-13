import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cone_drone/services/bluetooth.dart';

class BluetoothDeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  BluetoothDeviceTile({this.device});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BluetoothManager>(
      builder: (_, child, model) {
        return InkWell(
          onTap: () async {
            model.connectDevice(device);
          },
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Card(
              margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
              child: ListTile(
                leading: Icon(Icons.bluetooth, color: Colors.black54),
                title: Text('${device.name ?? 'No Name'}'),
                subtitle: Text('${device.address}'),
              ),
            ),
          ),
        );
      },
    );
  }
}
