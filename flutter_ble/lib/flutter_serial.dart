import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothManager {
  // class variables
  static final String deviceNamePattern = r'(^dronecone*)';
  static final RegExp deviceNameReg = RegExp(deviceNamePattern);

  // instance variables
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection connection;

  // Future<List<BluetoothDevice>> findDevices() async {
  //   List<BluetoothDevice> devices = [];
  //   List<String> addresses = [];
  //
  //   try {
  //     Timer(Duration(seconds: 5), _bluetooth.cancelDiscovery);
  //     _bluetooth.startDiscovery().listen((e) {
  //       if (!addresses.contains(e.device.address)) {
  //         addresses.add(e.device.address);
  //         devices.add(e.device);
  //       }
  //     }).onDone(() {
  //       print('\nFound ${devices.length} devices:');
  //       devices.forEach((device) {
  //         print('\t\tFound: ${device.name} ${device.address}');
  //       });
  //     });
  //   } on PlatformException {
  //     print("error");
  //     return null;
  //   }
  //   return devices
  //       .where((x) => x.name != null)
  //       .where((x) => deviceNameReg.hasMatch(x.name))
  //       .toList();
  // }

  Future<List<BluetoothDiscoveryResult>> get results {
    return _bluetooth.startDiscovery().toList();
  }

  Future<List<BluetoothDiscoveryResult>> findPis() async {
    Timer(Duration(seconds: 15), _bluetooth.cancelDiscovery);
    var deviceResults = await results;
    return deviceResults
        .where((x) => x.device.name != null)
        .where((x) => deviceNameReg.hasMatch(x.device.name))
        .toList();
  }

  void connectDevice(BluetoothDevice device) async {
    connection = await BluetoothConnection.toAddress(device.address);
  }

  // add bluetooth communication
}
