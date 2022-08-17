// let sql="DELETE FROM `friend` WHERE `uID1`=? AND `uID2`=?";
class DeleteFriendResponseModel {
  //String token;
  String error;

  DeleteFriendResponseModel({/*required this.token,*/ required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory DeleteFriendResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteFriendResponseModel(/*token: json["token"] != null ? json["token"]: "",*/ error: json["error"] != null ? json["error"]: "",);
  }
  //print(error);
}
class DeleteFriendRequestModel{
  int uID1;
  int uID2;

  DeleteFriendRequestModel({
    required this.uID1,
    required this.uID2,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uID1': uID1,
      'uID2': uID2,
    };

    return map;
  }
}