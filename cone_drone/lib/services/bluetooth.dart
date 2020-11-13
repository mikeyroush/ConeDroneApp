import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:typed_data';
import 'package:cone_drone/services/messages.dart';

enum ConeState { connected, disconnected }

class BluetoothManager extends Model {
  // class variables
  static final String deviceNamePattern = r'(^dronecone*)';
  static final RegExp deviceNameReg = RegExp(deviceNamePattern);

  // instance variables
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothDevice _host;
  BluetoothConnection _connection;
  Map<String, ConeState> mapCones = new Map<String, ConeState>();

  // add vars for total, activated, errors

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

  Future<List<BluetoothDiscoveryResult>> get discoveryResults {
    return _bluetooth.startDiscovery().toList();
  }

  Future<List<BluetoothDiscoveryResult>> findPis() async {
    Timer(Duration(seconds: 15), _bluetooth.cancelDiscovery);
    List<BluetoothDiscoveryResult> deviceResults = await discoveryResults;
    return deviceResults
        .where((x) => x.device.name != null)
        .where((x) => deviceNameReg.hasMatch(x.device.name))
        .toList();
  }

  Future<List<BluetoothDevice>> getPairedPis() async {
    List<BluetoothDevice> pairedDevices = await _bluetooth.getBondedDevices();
    return pairedDevices
        .where((x) => x.name != null)
        .where((x) => deviceNameReg.hasMatch(x.name))
        .toList();
  }

  // connect to a device and send initial message
  void connectDevice(BluetoothDevice device) async {
    // todo: disconnect from device if it already exists
    try {
      // establish connection
      _connection = await BluetoothConnection.toAddress(device.address);
      _host = device;
      mapCones[_host.name] = ConeState.connected;

      // send connection message to network
      Uint8List msg =
          Uint8List.fromList(craftMessage("connection", _host.name));
      print('Data outgoing: $msg');
      _connection.output.add(msg);

      // update children widgets and listen for network messages
      notifyListeners();
      networkMessages;
    } catch (e) {
      print('Cannot connect, exception occurred');
    }
  }

  // return connection status
  bool get isConnected {
    return _connection != null && _connection.isConnected;
  }

  String get hostName {
    return _host != null ? _host.name : 'Not Connected';
  }

  // listen for network messages
  void get networkMessages {
    _connection.input.listen((Uint8List data) {
      // parse input
      var msg = parseMessage(Uint8List.fromList(data));
      print('Data incoming: $msg');

      // handle input accordingly
      Uint8List out;
      switch (msg[0]) {
        case "indicating":
          {
            out = Uint8List.fromList(
                craftMessage("ack", _host.name, num: msg[2]));
            break;
          }
        case "new node":
          {
            out = Uint8List.fromList(
                craftMessage("ack", _host.name, num: msg[2]));
            mapCones[msg[3]] = ConeState.connected;
            notifyListeners();
            break;
          }
      }

      // send acknowledgement
      if (out != null) {
        print('Data outgoing: $out');
        _connection.output.add(out);
      }
    }).onDone(() {
      print('Disconnected by remote request');
      _host = null;
      mapCones.clear();
      notifyListeners();
    });
  }

  // send reset message to network
  void sendReset() {
    Uint8List resetMsg =
        Uint8List.fromList(craftMessage("reset all", _host.name));
    print('Sending reset all...');
    _connection.output.add(resetMsg);
  }
}
