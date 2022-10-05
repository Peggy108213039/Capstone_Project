import 'package:capstone_project/services/http_service.dart';

// class SelectInfoResponseModel {
//   // int uID;
//   String user_account;
//   String user_name;
//   String result;

//   SelectInfoResponseModel({
//     // required this.uID,
//     required this.user_account,
//     required this.user_name,
//     required this.result});

//   /// `toJson` is the convention for a class to declare support for serialization
//   /// to JSON. The implementation simply calls the private, generated
//   /// helper method `_$UserToJson`.
//   factory SelectInfoResponseModel.fromJson(Map<String, dynamic> json) {
//     return SelectInfoResponseModel(
//       // uID: json["uID"] ?? "", // if null then return ""
//       user_account: json["account"] ?? "",
//       user_name: json["name"] ?? "",
//       result: json["result"] ?? "",
//     );
//   }
// }

class SelectInfoRequestModel{
  String uid;

  SelectInfoRequestModel({required this.uid});

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uID': uid,
    };

    return map;
  }
}