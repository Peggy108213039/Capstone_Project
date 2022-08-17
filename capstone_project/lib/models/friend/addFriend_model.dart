// let sql="INSERT INTO `friend`(`uID1`,`uID2`) VALUES (?,?)";
class AddFriendResponseModel {
  //String token;
  String error;

  AddFriendResponseModel({/*required this.token,*/ required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory AddFriendResponseModel.fromJson(Map<String, dynamic> json) {
    return AddFriendResponseModel(/*token: json["token"] != null ? json["token"]: "",*/ error: json["error"] != null ? json["error"]: "",);
  }
  //print(error);
}
class AddFriendRequestModel{
  int uID1;
  int uID2;

  AddFriendRequestModel({
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