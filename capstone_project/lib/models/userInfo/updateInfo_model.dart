import 'package:capstone_project/services/http_service.dart';

class UpdateInfoResponseModel {

  int uID;
  String account;
  String name;
  String password;
  String email;
  String phone;
  String result;

  UpdateInfoResponseModel({
    required this.uID,
    required this.account,
    required this.name,
    required this.password,
    required this.email,
    required this.phone,
    required this.result});

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory UpdateInfoResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateInfoResponseModel(
      uID: json["uID"] ?? "", // if null then return ""
      account: json["account"] ?? "",
      name: json["name"] ?? "",
      password: json["password"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      result: json["result"] ?? "",
    );
  }
}
class UpdateInfoRequestModel{
  int uid; 
  String name;
  String account;
  String password;
  String email;
  String phone;

  UpdateInfoRequestModel({
    required this.uid,
    required this.name,
    required this.account,
    required this.password,
    required this.email,
    required this.phone
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uid': UserData.uid.toString(),
      'account': UserData.userAccount, // account 唯一，不可修改
      'name': name.trim(),
      'password': password.trim(),
      'email': email.trim(),
      'phone': phone.toString()
    };

    return map;
  }
}