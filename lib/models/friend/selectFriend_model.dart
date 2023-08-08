// let sql="SELECT * FROM `friend` WHERE `uID1`=?";

// class SelectFriendResponseModel {
//   late List friends;
//   //List<int> friendList = [];
//   late String error;

//   SelectFriendResponseModel({required this.friends,/*required this.friendList,*/ required this.error});
  
//   /// `toJson` is the convention for a class to declare support for serialization
//   /// to JSON. The implementation simply calls the private, generated
//   /// helper method `_$UserToJson`.
//   /// fromJson：把 response(json) 轉回來
//   /// 故 SelectFriendResponseModel 為非 json 格式
//   factory SelectFriendResponseModel.fromJson(Map<List, dynamic> json) {
//     // List<int> tmpList = [];
//     // json.map((key, value) => null)
//     // for (var friend in json) {
//     //   tmpList.add(friend['uID2']);
//     // }
//     // print("MODEL 中的 json response");
//     // print(tmpList);
//     return SelectFriendResponseModel(friends: (json["uid2"]) ?? ""/*,friendList: tmpList*/, error: json["error"] ?? "",);
//   }
//   //print(error);
// }
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
      'uID': uID1
    };

    return map;
  }
}