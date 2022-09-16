//import 'dart:html';

class LoginResponseModel {
  int uID;
  String account;
  String name;
  String password;
  String email;
  int phone;
  int totalDiatance;
  int totalTime;
  int totalActivity;
  int totalTrack;
  String result;

  LoginResponseModel({
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
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
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
class LoginRequestModel{
  String account;
  String password;

  LoginRequestModel({
    required this.account,
    required this.password,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'account': account.trim(),
      'password': password.trim(),
    };

    return map;
  }
}