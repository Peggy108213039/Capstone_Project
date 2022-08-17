// let sql="SELECT * FROM `friend` WHERE `uID1`=?";

class SelectFriendResponseModel {
  //String token;
  String error;

  SelectFriendResponseModel({/*required this.token,*/ required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory SelectFriendResponseModel.fromJson(Map<String, dynamic> json) {
    return SelectFriendResponseModel(/*token: json["token"] != null ? json["token"]: "",*/ error: json["error"] != null ? json["error"]: "",);
  }
  //print(error);
}
class SelectFriendRequestModel{
  int uID1;

  SelectFriendRequestModel({
    required this.uID1,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uID1': uID1
    };

    return map;
  }
}