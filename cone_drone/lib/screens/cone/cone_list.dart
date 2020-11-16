import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/screens/cone/cone_tile.dart';

class ConeList extends StatefulWidget {
  @override
  _ConeListState createState() => _ConeListState();
}

class _ConeListState extends State<ConeList> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BluetoothManager>(
      builder: (_, child, model) {
        return model.connecting
            ? Center(
                child: SpinKitFoldingCube(
                  color: Colors.white70,
                  size: 50.0,
                ),
              )
            : ListView.builder(
                itemCount: model.mapCones.length,
                itemBuilder: (context, index) {
                  return ConeTile(
                    name: model.mapCones.keys.elementAt(index),
                    state: model.mapCones.values.elementAt(index),
                  );
                },
              );
      },
    );
  }
}
