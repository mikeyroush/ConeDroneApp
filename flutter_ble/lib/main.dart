import 'package:flutter/material.dart';
import 'package:flutter_ble/flutter_serial.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: Text('Flutter BLE'),
            backgroundColor: Colors.blueGrey.shade800,
          ),
          backgroundColor: Colors.blueGrey,
          body: HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BluetoothManager _bluetoothManager = BluetoothManager();
  bool _showDevices = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlatButton.icon(
              onPressed: () => setState(() => _showDevices = !_showDevices),
              icon: Icon(
                Icons.bluetooth,
                color: Colors.white70,
              ),
              label: Text(
                _showDevices ? 'Hide Devices' : 'Show Devices',
                style: TextStyle(color: Colors.white70),
              ),
              color: Colors.blueGrey.shade800,
            ),
            if (_showDevices)
              Expanded(
                child: FutureBuilder<List<BluetoothDiscoveryResult>>(
                  future: _bluetoothManager.findPis(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      snapshot.data.forEach((element) {
                        print('Building: ${element.device.address}');
                      });
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return snapshot.data.length > 0
                              ? BluetoothDeviceTile(
                                  device: snapshot.data[index].device)
                              : Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Card(
                                    margin: EdgeInsets.fromLTRB(
                                        20.0, 6.0, 20.0, 0.0),
                                    child: ListTile(
                                      leading: Icon(Icons.bluetooth,
                                          color: Colors.black54),
                                      title: Text('No cones found'),
                                      subtitle: Text(
                                          'Press the button twice to search again.'),
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
                      return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BluetoothDeviceTile extends StatelessWidget {
  final FlutterBluetoothSerial _bluetoothSerial =
      FlutterBluetoothSerial.instance;
  final BluetoothDevice device;
  BluetoothDeviceTile({this.device});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          print('Attempting to connect to: ${device.address}');
          BluetoothConnection connection =
              await BluetoothConnection.toAddress(device.address);
          print('Connected to the device');

          connection.input.listen((Uint8List data) {
            print('Data incoming: ${ascii.decode(data)}');
            connection.output.add(data); // Sending data

            if (ascii.decode(data).contains('!')) {
              connection.finish(); // Closing connection
              print('Disconnecting by local host');
            }
          }).onDone(() {
            print('Disconnected by remote request');
          });
        } catch (exception) {
          print('Cannot connect, exception occurred');
          print(exception.toString());
        }
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
  }
}
