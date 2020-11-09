import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cone_drone/models/user.dart';
import 'package:cone_drone/models/pilot.dart';
import 'package:cone_drone/models/flight.dart';

class DatabaseService {
  final String instructorID;
  final String pilotID;
  final String flightID;
  DatabaseService({this.instructorID, this.pilotID, this.flightID});

  // ****************************
  // ********** PILOTS **********
  // ****************************

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
    // delete flight records for pilot
    Stream<QuerySnapshot> flightRecords =
        flightCollection.where('pilotID', isEqualTo: pilotID).snapshots();
    flightRecords.forEach((record) {
      record.docs.forEach((doc) async {
        await flightCollection.doc(doc.id).delete();
      });
    });

    // delete pilot
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

  // *****************************
  // ********** FLIGHTS **********
  // *****************************

  // collection reference
  final CollectionReference flightCollection =
      FirebaseFirestore.instance.collection('flights');

  // create new flight record
  Future addFlight(String pilotID, int totalCones, int activatedCones,
      int timeElapsedMilli) async {
    return await flightCollection.add({
      'pilotID': pilotID,
      'totalCones': totalCones,
      'activatedCones': activatedCones,
      'timeElapsedMilli': timeElapsedMilli,
      'timeStamp': DateTime.now(),
    });
  }

  // delete flight record
  Future deleteFlight() async {
    return await flightCollection.doc(flightID).delete();
  }

  // flight list from snapshot
  List<Flight> _flightListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Flight(
        uid: doc.id ?? '',
        totalCones: doc.data()['totalCones'] ?? 0,
        activatedCones: doc.data()['activatedCones'] ?? 0,
        timeElapsedMilli: doc.data()['timeElapsedMilli'] ?? 0,
        timeStamp:
            (doc.data()['timeStamp'] as Timestamp).toDate() ?? DateTime.now(),
        pilotID: doc.data()['pilotID'] ?? '',
      );
    }).toList();
  }

  // get flights stream
  Stream<List<Flight>> get flights {
    return flightCollection
        .where('pilotID', isEqualTo: pilotID)
        .orderBy('timeStamp')
        .snapshots()
        .map(_flightListFromSnapshot);
  }
}
