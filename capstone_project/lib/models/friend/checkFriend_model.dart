// let sql="SELECT * FROM `friend` WHERE `uID1`=? AND `uID2`=?";
class CheckFriendResponseModel {
  //String token;
  String error;

  CheckFriendResponseModel({/*required this.token,*/ required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory CheckFriendResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckFriendResponseModel(/*token: json["token"] != null ? json["token"]: "",*/ error: json["error"] != null ? json["error"]: "",);
  }
  //print(error);
}
class CheckFriendRequestModel{
  int uID1;
  int uID2;

  CheckFriendRequestModel({
    required this.uID1,
    required this.uID2,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uID1': uID1.toString(),
      'uID2': uID2.toString(),
    };

    return map;
  }
}