//import 'dart:html';

class getInfoResponseModel {
  int uID;
  String account;
  String name;
  String password;
  String email;
  String phone;
  int totalDiatance;
  int totalTime;
  int totalActivity;
  int totalTrack;
  String result;

  getInfoResponseModel({
    required this.uID,
    required this.account,
    required this.name,
    required this.password,
    required this.email,
    required this.phone,
    required this.totalDiatance,
    required this.totalTime,
    required this.totalActivity,
    required this.totalTrack,
    required this.result});

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory getInfoResponseModel.fromJson(Map<String, dynamic> json) {
    return getInfoResponseModel(
      uID: json["uID"] ?? "", // if null then return ""
      account: json["account"] ?? "",
      name: json["name"] ?? "",
      password: json["password"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      totalDiatance: json["total_distance"],
      totalTime: json["total_time"],
      totalActivity: json["total_activity"],
      totalTrack: json["total_track"],
      result: json["result"] ?? "",
    );
  }
  //print(error);
}
class getInfoRequestModel{
  String uID;

  getInfoRequestModel({
    required this.uID,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uID': uID.trim(),
    };

    return map;
  }
}