import 'package:flutter/material.dart';
import 'package:flutter_ble/flutter_ble.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'dart:async';
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
  Future<List<BluetoothDiscoveryResult>> _results;

  @override
  void initState() {
    super.initState();
    _updateDeviceResults();
  }

  Future<void> _updateDeviceResults() async {
    _results = BluetoothManager.findDevices();
    Timer(Duration(seconds: 5),
        () => FlutterBluetoothSerial.instance.cancelDiscovery());
  }

  // Todo: fix swipe to refresh cone list

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<BluetoothDiscoveryResult>>(
        future: _results,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator(
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return BluetoothDeviceTile(result: snapshot.data[index]);
                },
              ),
              onRefresh: _updateDeviceResults,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error.toString()}',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          } else
            return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class BluetoothDeviceTile extends StatelessWidget {
  final BluetoothDiscoveryResult result;
  BluetoothDeviceTile({this.result});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          BluetoothConnection connection =
              await BluetoothConnection.toAddress(result.device.address);
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
          print('Cannot connect, exception occured');
        }
      },
      child: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Card(
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            leading: Icon(Icons.bluetooth, color: Colors.black54),
            title: Text('${result.device.name}'),
            subtitle: Text('${result.device.address}'),
          ),
        ),
      ),
    );
  }
}
