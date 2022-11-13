// let sql="SELECT * FROM `friend` WHERE `uID1`=? AND `uID2`=?";
class CheckFriendResponseModel {
  //String token;
  String error;

  CheckFriendResponseModel({/*required this.token,*/ required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory CheckFriendResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckFriendResponseModel(/*token: json["token"] != null ? json["token"]: "",*/ error: json["error"] ?? "",);
  }
  //print(error);
}
class CheckFriendRequestModel{
  String uID1;
  String friendAccount;

  CheckFriendRequestModel({
    required this.uID1,
    required this.friendAccount,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uID1': uID1,
      'uID2': friendAccount,
    };

    return map;
  }
}