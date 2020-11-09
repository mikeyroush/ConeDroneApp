// some dart code

// import 'package:flutter/material.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
import 'messages.dart' as messages;

BluetoothConnection connectBluetooth() {
	try {
		BluetoothConnection connection = await BluetoothConnection.toAddress(address);
		print('Connected to the device');
	}
	catch (exception) {
		print("why don't you go ask your mother");
	}
}

void messageListen(connection) {
	// receive the incoming message
	connection.input.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');

		// parse the message
		messages.parseMessage(data);

		// 
        if (ascii.decode(data).contains('!')) {
            connection.finish(); // Closing connection
            print('Disconnecting by local host');
        }
    }).onDone(() {
        print('Disconnected by remote request');
    });
}


void messageSend(connection) {
	connection.output.add(data); // Sending data
}
