// messages.py but it's dart
// ooooooooh

import 'dart:typed_data';

List parseMessage(msg) {

    var bytes = msg.buffer.asByteData();
	
	var first_num = bytes.getInt32(0).toUnsigned(32);
	var second_num = bytes.getInt32(4).toUnsigned(32);

	var msg_type = "";
	
	switch ((first_num & 0xFF000000) >> 24) {
		case 0: {
			// reset
			print("why don't you go ask your father");
      break;
		}
		case 1: {
			// indicate
			msg_type = "indicate";
      break;
		}
		case 2: {
			// new node
			msg_type = "new node";
      break;
		}
		case 3: {
			// node lost
			msg_type = "node lost";
      break;
		}
		case 4: {
			// reset all
			print("why don't you go ask your father");
      break;
		}
		case 5:	{
			// ack
			msg_type = "ack";
      break;
		}
  }
			
	var msg_node = "dronecone" + (first_num & 0x00000FFF).toString();
	
    var msg_num = second_num.toString();
  
	// only for "new node" and "node lost"
	var msg_node2 = "dronecone" + ((first_num >> 12) & 0x00000FFF).toString();
	
	var msg_info = new List(4);
	
	msg_info[0] = msg_type;
	msg_info[1] = msg_node;
	msg_info[2] = msg_num;
	msg_info[3] = msg_node2;
  
  return msg_info;
}

Uint8List craftMessage(type, name, {num : -1, name2: "dronecone???"}) {

	var msg_int = 0;
	
	switch (type) {
		case "reset": {
			break;
		}
		case "indicate": {
			msg_int = msg_int | 0x0100000000000000;
			break;
		}
		case "new node": {
			msg_int = msg_int | 0x0200000000000000;
			break;
		}
		case "node lost": {
			msg_int = msg_int | 0x0300000000000000;
			break;
		}
		case "reset all": {
			msg_int = msg_int | 0x0400000000000000;
			break;
		}
		case "ack": {
			msg_int = msg_int | 0x0500000000000000;
			break;		
		}
	}
	
	if (name2 != "dronecone???") {
		var msg_node2 = int.parse(name2.substring(9));
		msg_int = msg_int | (msg_node2 << 44);
	} 
	
	var msg_node = int.parse(name.substring(9));
	msg_int = msg_int | (msg_node << 32);

    print(num);

	if (num != -1) {
		var msg_num = int.parse(num);
		msg_int = msg_int | (msg_num);
	}
	
	var msg = new Uint8List(8);
	msg[0] = ((msg_int & 0xFF00000000000000) >> 56);
	msg[1] = ((msg_int & 0x00FF000000000000) >> 48);
	msg[2] = ((msg_int & 0x0000FF0000000000) >> 40);
	msg[3] = ((msg_int & 0x000000FF00000000) >> 32);
	msg[4] = ((msg_int & 0x00000000FF000000) >> 24);
	msg[5] = ((msg_int & 0x0000000000FF0000) >> 16);
	msg[6] = ((msg_int & 0x000000000000FF00) >> 8);
	msg[7] = (msg_int & 0x00000000000000FF);

	return msg;

}



