// let sql="SELECT * FROM `friend` WHERE `uID1`=?";

class SelectFriendResponseModel {
  List friends;
  String error;

  SelectFriendResponseModel({required this.friends, required this.error});
  
  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  factory SelectFriendResponseModel.fromJson(Map<List, dynamic> json) {
    return SelectFriendResponseModel(friends: (json["uid2"]) ?? "", error: json["error"] ?? "",);
  }
  //print(error);
}
class SelectFriendRequestModel{
  String uID1;

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