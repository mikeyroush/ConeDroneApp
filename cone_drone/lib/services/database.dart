import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/models/pilot.dart';

class DatabaseService {
  final String instructorID;
  final String pilotID;
  DatabaseService({this.instructorID, this.pilotID});

  // collection reference
  final CollectionReference pilotCollection =
      FirebaseFirestore.instance.collection('pilots');

  // update pilot data
  Future updatePilotData(
      String name, String email, String phone, String instructorID) async {
    return await pilotCollection.doc(pilotID).set({
      'name': name,
      'email': email,
      'phone': phone,
      'instructorID': instructorID,
    });
  }

  // create new pilot
  Future addPilot(String name, String email, String phone) async {
    return await pilotCollection.add({
      'name': name,
      'email': email,
      'phone': phone,
      'instructorID': instructorID,
    });
  }

  // delete pilot
  Future deletePilot() async {
    return await pilotCollection.doc(pilotID).delete();
  }

  // pilot list from snapshot
  List<Pilot> _pilotListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Pilot(
        uid: doc.id ?? '',
        name: doc.data()['name'] ?? '',
        email: doc.data()['email'] ?? '',
        phone: doc.data()['phone'] ?? '',
        instructorID: doc.data()['instructorID'] ?? '',
      );
    }).toList();
  }

  // get pilots stream
  Stream<List<Pilot>> get pilots {
    return pilotCollection
        .where('instructorID', isEqualTo: instructorID)
        .orderBy('name')
        .snapshots()
        .map(_pilotListFromSnapshot);
  }

  // user data from snapshot
  // get user doc stream
}
