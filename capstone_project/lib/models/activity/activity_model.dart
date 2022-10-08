class Activity {
  // final String aID;
  final String uID;
  final String activity_name;
  final String activity_time;
  final String tID;
  final String warning_distance;
  final String warning_time;

  Activity(
      {
      // required this.aID,
      required this.uID,
      required this.activity_name,
      required this.activity_time,
      required this.tID,
      required this.warning_distance,
      required this.warning_time});

  @override
  String toString() {
    return '''Activity{
      uID: $uID, 
      activity_name: $activity_name, 
      activity_time: $activity_time, 
      tID: $tID, 
      warning_distance: $warning_distance, 
      warning_time: $warning_time}''';
  }

  Map<String, dynamic> toMap() {
    return {
      'uID': uID,
      'activity_name': activity_name,
      'activity_time': activity_time,
      'tID': tID,
      'warning_distance': warning_distance,
      'warning_time': warning_time,
    };
  }
}
