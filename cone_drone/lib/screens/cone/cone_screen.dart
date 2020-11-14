import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/screens/cone/bluetooth_list.dart';
import 'package:cone_drone/screens/cone/cone_list.dart';
import 'package:cone_drone/constants.dart';

enum Status { none, connected, disconnected }

class ConeScreen extends StatefulWidget {
  @override
  _ConeScreenState createState() => _ConeScreenState();
}

class _ConeScreenState extends State<ConeScreen> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BluetoothManager>(
      builder: (_, child, model) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FlatButton.icon(
                  onPressed: () => setState(() => model.toggleShowDevices()),
                  icon: Icon(
                    Icons.bluetooth,
                    color: Colors.white70,
                  ),
                  label: Text(
                    model.showDevices ? 'Hide Devices' : 'Show Devices',
                    style: kTextFieldStyle,
                  ),
                  color: Colors.blueGrey.shade800,
                ),
                if (model.showDevices)
                  Expanded(
                    flex: 2,
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                model.isConnected
                                    ? 'Select new host:'
                                    : 'Select a host:',
                                style: kMenuTextStyle,
                              ),
                            ),
                            Expanded(child: BluetoothList()),
                          ],
                        )),
                  ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(top: 8.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Host: ${model.hostName.toUpperCase()}",
                            style: kMenuTextStyle.copyWith(
                                color: model.isConnected
                                    ? Colors.green.shade900
                                    : Colors.redAccent),
                          ),
                        ),
                        Expanded(child: ConeList()),
                        if (model.isConnected)
                          FlatButton.icon(
                            onPressed: () => model.sendResetAll(),
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.white70,
                            ),
                            label: Text(
                              'Reset Network',
                              style: kTextFieldStyle,
                            ),
                            color: Colors.blueAccent,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
