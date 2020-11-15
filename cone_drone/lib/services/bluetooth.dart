import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:typed_data';
import 'package:cone_drone/services/messages.dart';

enum ConeState { connected, disconnected, indicating }

class BluetoothManager extends Model {
  // class variables
  static final String deviceNamePattern = r'(^dronecone*)';
  static final RegExp deviceNameReg = RegExp(deviceNamePattern);

  // instance variables
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  final Stopwatch stopwatch = Stopwatch();
  BluetoothDevice _host;
  BluetoothConnection _connection;
  Map<String, ConeState> mapCones = new Map<String, ConeState>();
  int numConnected = 0;
  int numActivated = 0;
  bool _showDevices = true;

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

  // return connection status

  bool get isConnected {
    return _connection != null && _connection.isConnected;
  }

  // return show device status
  bool get showDevices {
    return _showDevices;
  }

  // toggle show device status
  void toggleShowDevices() {
    _showDevices = !_showDevices;
    notifyListeners();
  }

  // return host's name
  String get hostName {
    return _host != null ? _host.name : 'None';
  }

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
    // disconnect current device
    if (_connection != null &&
        _connection.isConnected &&
        _host.name != device.name) {
      await _connection.finish();
      mapCones.clear();
    }

    try {
      // establish connection
      _connection = await BluetoothConnection.toAddress(device.address);
      _host = device;
      mapCones[_host.name] = ConeState.connected;
      _showDevices = false;

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

  // listen to network
  Stream<Uint8List> get networkListener {
    return _connection.input;
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
            mapCones[msg[1]] = ConeState.indicating;
            numActivated++;
            break;
          }
        case "new node":
          {
            out = Uint8List.fromList(
                craftMessage("ack", _host.name, num: msg[2]));
            mapCones[msg[3]] = ConeState.connected;
            numConnected++;
            break;
          }
        case "id":
          {
            out = Uint8List.fromList(
                craftMessage("ack", _host.name, num: msg[2]));
            mapCones[msg[1]] = ConeState.connected;
            numConnected++;
            break;
          }
        case "node lost":
          {
            out = Uint8List.fromList(
                craftMessage("ack", _host.name, num: msg[2]));
            mapCones[msg[3]] = ConeState.disconnected;
            numConnected--;
            break;
          }
      }

      // update listeners
      notifyListeners();

      // send acknowledgement
      if (out != null) {
        print('Data outgoing: $out');
        _connection.output.add(out);
      }
    }).onDone(() {
      print('Disconnected by remote request');
      _host = null;
      _showDevices = true;
      mapCones.clear();
      notifyListeners();
    });
  }

  // send reset all message to network
  void sendResetAll() {
    Uint8List resetMsg =
        Uint8List.fromList(craftMessage("reset all", _host.name));
    print('Sending reset all...');
    _connection.output.add(resetMsg);

    // update cone map
    mapCones.forEach((key, value) {
      if (value == ConeState.indicating) mapCones[key] = ConeState.connected;
    });
    numActivated = 0;
    notifyListeners();
  }

  // send reset cone message
  void sendReset(String name) {
    Uint8List resetMsg = Uint8List.fromList(craftMessage("reset", name));
    print('Sending reset to $name...');
    _connection.output.add(resetMsg);

    // update cone map
    mapCones[name] = ConeState.connected;
    numActivated--;
    notifyListeners();
  }

  // send do indicate message
  void sendDoIndicate(String name) {
    Uint8List indicateMsg =
        Uint8List.fromList(craftMessage("do indicate", name));
    print('Sending do inidcate to $name...');
    _connection.output.add(indicateMsg);

    // update cone map
    mapCones[name] = ConeState.indicating;
    numActivated++;
    notifyListeners();
  }

  // send power off message
  void sendDisconnect(String name) {
    Uint8List disconnectMsg =
        Uint8List.fromList(craftMessage("disconnect", name));
    print('Sending do disconnect to $name...');
    _connection.output.add(disconnectMsg);

    // Don't need to update mapCones ... wait for node lost
  }

  // send power off all message
  void sendDisconnectAll() {
    Uint8List disconnectMsg =
        Uint8List.fromList(craftMessage("disconnect all", _host.name));
    print('Sending disconnect all...');
    _connection.output.add(disconnectMsg);

    // update cone map
    mapCones.forEach((key, value) {
      mapCones[key] = ConeState.disconnected;
    });
    numConnected = 0;
    notifyListeners();
  }
}
