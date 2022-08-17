//FIXME 0809
//let sql="UPDATE `activity` SET `activity_time`=? WHERE `aID`=?";

class FinishActivityResponseModel {
  //String token;
  String error;

  FinishActivityResponseModel({/*required this.token,*/ required this.error});

  factory FinishActivityResponseModel.fromJson(Map<String, dynamic> json) {
    return FinishActivityResponseModel(/*token: json["token"] != null ? json["token"]: "",*/ error: json["error"] != null ? json["error"]: "",);
  }
  //print(error);
}
class FinishActivityRequestModel{
  String activity_time;
  int aID;

  FinishActivityRequestModel({
    required this.activity_time,
    required this.aID,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'activity_time': activity_time.trim(),
      'aID': aID,
    };

    return map;
  }
}