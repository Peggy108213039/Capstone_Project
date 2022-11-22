// let sql="SELECT * FROM `friend` WHERE `uID1`=? AND `uID2`=?";
class InviteFriendResponseModel {
  //String token;
  String error;

  InviteFriendResponseModel({/*required this.token,*/ required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory InviteFriendResponseModel.fromJson(Map<String, dynamic> json) {
    return InviteFriendResponseModel(/*token: json["token"] != null ? json["token"]: "",*/ error: json["error"] ?? "",);
  }
  //print(error);
}
class InviteFriendRequestModel{
  String uID1;
  String friendAccount;

  InviteFriendRequestModel({
    required this.uID1,
    required this.friendAccount,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uID1': uID1,
      'friend': friendAccount,
    };

    return map;
  }
}