// handling receiving messages in dart

/*

globals.dart

network_map = new Map() // map each node to a list of its connections
//message_queue 		// <---- not necessary if the phone is only connected to one node
//unack_msgs			// not sure how to do this yet

*/



// we need to import this
import 'messages.dart' as messages;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'dart:math';
import 'globals.dart' as globals;

// connection is of type BluetoothConnection
void receiveMessages(connection) {

	// probably don't want it to be infinite on the real thing
	while (true) {
		
		connection.input.listen((Uint8List msg) {
			print("message incoming: $(ascii.decode(msg))");
		}
		
		List msg_info = messages.parseMessage(msg);
		
		switch (msg_info[0]) {
			case "reset": {
				// should not be receiving this
				break;
			}
			case "indicating": {
				print("handling indicating");
				// need to update cone status in dashboard page
				// also need to add one to flyovers if we are recording
				// TODO: all of that jazz
				
				// send acknowledgement
				msg_ack = messages.craftMessage("ack", "dronecone0", msg_info[2]);
				connection.output.add(msg_ack);
				
				break;
			}
			case "new node": {
				print("handling new node");
				// add new node to globals.network_map if not there already
				if (!(globals.network_map.containsKey(msg_info[3]))) {
					globals.network_map[msg_info[3]] = new List<String>();
				
				// add nodes to each others lists
				globals.network_map[msg_info[3]].add(msg_info[1]);
				globals.network_map[msg_info[1]].add(msg_info[3]);
				
				// send acknowledgement
				msg_ack = messages.craftMessage("ack", "dronecone0", msg_info[2]);
				connection.output.add(msg_ack);
				
				break;
			}
			case "node lost": {
				print("handling node lost");
				// for node in map, search list for node2 and delete
				globals.network_map[msg_info[1]].remove(msg_info[3]);
				
				// send acknowledgement
				msg_ack = messages.craftMessage("ack", "dronecone0", msg_info[2]);
				connection.output.add(msg_ack);
				
				break;
			}
			case "reset all": {
				// should not be receiving this
				break;
			}
			case "ack": {
				print("handling ack");
				// do nothing
				break;
			}
			case "do indicate": {
				// should not be receiving this 
				break;
			}
			case "phone connect": {
				// should not be receiving this
				break;
			}
			case "phone lost": {
				// should not be receiving this 
				break;
			}
			default: {
				print("couldn't understand received message");
				break;
			}
		}		
	}
}


