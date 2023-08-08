// let sql="INSERT INTO `friend`(`uID1`,`uID2`) VALUES (?,?)";
class InsertFriendResponseModel {
  //String token;
  String error;

  InsertFriendResponseModel({/*required this.token,*/ required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory InsertFriendResponseModel.fromJson(Map<String, dynamic> json) {
    return InsertFriendResponseModel(/*token: json["token"] != null ? json["token"]: "",*/ error: json["error"] ?? "",);
  }
  //print(error);
}
class InsertFriendRequestModel{
  String uID1;
  String account;

  InsertFriendRequestModel({
    required this.uID1,
    required this.account,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uID2': uID1,
      'friend': account,
    };

    return map;
  }
}