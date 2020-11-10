import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothManager {
  // Discover bluetooth device
  static final String deviceNamePattern = r'(^dronecone*)';
  static final RegExp deviceNameReg = RegExp(deviceNamePattern);

  static Future<List<BluetoothDiscoveryResult>> get results {
    return FlutterBluetoothSerial.instance.startDiscovery().toList();
  }

  static Future<List<BluetoothDiscoveryResult>> findDevices() async {
    print('called');
    var deviceResults = await results;
    print('have results');
    return deviceResults
        .where((x) => x.device.name != null)
        .where((x) => deviceNameReg.hasMatch(x.device.name))
        .toList();
  }
}
