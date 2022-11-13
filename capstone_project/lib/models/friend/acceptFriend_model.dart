// let sql="INSERT INTO `friend`(`uID1`,`uID2`) VALUES (?,?)";
class AcceptFriendResponseModel {
  //String token;
  String error;

  AcceptFriendResponseModel({/*required this.token,*/ required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory AcceptFriendResponseModel.fromJson(Map<String, dynamic> json) {
    return AcceptFriendResponseModel(/*token: json["token"] != null ? json["token"]: "",*/ error: json["error"] ?? "",);
  }
  //print(error);
}
class AcceptFriendRequestModel{
  String uID1;
  String account;

  AcceptFriendRequestModel({
    required this.uID1,
    required this.account,
  });

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'uID1': uID1,
      'account': account,
    };

    return map;
  }
}