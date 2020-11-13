import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cone_drone/screens/cone/bluetooth_tile.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:scoped_model/scoped_model.dart';

class BluetoothList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BluetoothManager>(
      builder: (_, child, model) {
        return FutureBuilder<List<BluetoothDevice>>(
          future: model.getPairedPis(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              snapshot.data.forEach((element) {
                print('Building: ${element.address}');
              });
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return snapshot.data.isNotEmpty
                      ? BluetoothDeviceTile(device: snapshot.data[index])
                      : Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Card(
                            margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                            child: ListTile(
                              leading:
                                  Icon(Icons.bluetooth, color: Colors.black54),
                              title: Text('No cones found...'),
                              subtitle: Text("Pair a cone in Settings"),
                            ),
                          ),
                        );
                },
              );
            } else if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.redAccent),
              );
            } else
              return Center(
                child: SpinKitFoldingCube(
                  color: Colors.white70,
                  size: 50.0,
                ),
              );
          },
        );
      },
    );
  }
}
