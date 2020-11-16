import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:cone_drone/services/bluetooth.dart';
import 'package:cone_drone/constants.dart';

class DisabledBluetooth extends StatefulWidget {
  @override
  _DisabledBluetoothState createState() => _DisabledBluetoothState();
}

class _DisabledBluetoothState extends State<DisabledBluetooth> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BluetoothManager>(
      builder: (_, child, model) {
        return StreamBuilder<BluetoothState>(
          stream: model.bluetoothStateChange,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == BluetoothState.STATE_OFF) {
              return BluetoothMessageScreen();
            } else if (!snapshot.hasData) {
              return FutureBuilder(
                future: model.bluetoothState,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data == BluetoothState.STATE_OFF) {
                    return BluetoothMessageScreen();
                  }
                  return SizedBox();
                },
              );
            }
            return SizedBox();
          },
        );
      },
    );
  }
}

class BluetoothMessageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Please enable bluetooth before proceeding.",
                style: kTitleTextStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
