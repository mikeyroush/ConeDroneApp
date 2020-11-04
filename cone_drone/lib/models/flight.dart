class Flight {
  final String uid;
  final String pilotID;
  final int totalCones;
  final int activatedCones;
  final int timeElapsedMilli;
  final DateTime timeStamp;

  Flight(
      {this.uid,
      this.pilotID,
      this.totalCones,
      this.activatedCones,
      this.timeElapsedMilli,
      this.timeStamp});
}
