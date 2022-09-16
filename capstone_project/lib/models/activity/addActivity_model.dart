// let sql="INSERT INTO `activity`(`uID`, `activity_name`, `activity_time`, `tID`, `warning_distance`, `warning_time`) VALUES (?,?,?,?,?,?)";

class AddActivityResponseModel {
  bool addDone;

  AddActivityResponseModel({required this.addDone});

  factory AddActivityResponseModel.fromJson(Map<String, dynamic> json) {
    return AddActivityResponseModel(addDone: json["addDone"] ?? "",);
  }
}
class AddActivityRequestModel{
  String uID;
  String activityName;
  String activityTime;
  String tID;
  int warnDistance;
  String warnTime;

  AddActivityRequestModel({
    required this.uID, // host
    required this.activityName,
    required this.activityTime,
    required this.tID, // traceID
    required this.warnDistance,
    required this.warnTime,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uID': uID.trim(),
      'activity_name': activityName.trim(),
      'activity_time': activityTime.trim(),
      'tID': tID.trim(),
      'warning_distance': warnDistance,
      'warning_time': warnTime.trim(),
    };

    return map;
  }
}