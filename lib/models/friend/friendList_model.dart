import 'package:flutter/material.dart';
class Friend{
  String name;
  String tel;

  Friend(this.name, this.tel);
}
class FriendViewModel extends ChangeNotifier {
  FriendViewModel() {
    filterFriends = _allFriend;
  }
  
  TextEditingController searchController = TextEditingController();

  late List<Friend> filterFriends;
  final List<Friend> _allFriend = [
    Friend("Peggy", "000-000000"),
    Friend("Hueilin", "111-000000"),
    Friend("Chinyuan", "222-000000"),
    Friend("Chiyuan", "333-000000"),
    Friend("John", "444-000000"),
    Friend("Hanweii", "555-000000"),
    Friend("Uncle", "666-000000"),
    Friend("Joanna", "777-000000"),
  ];

  searchFieldOnChanged(String value){
    filterFriends = [];
    for (var friend in _allFriend) {
      if (friend.name.contains(value) || friend.tel.contains(value)) {
        filterFriends.add(friend);
      }
    }
    notifyListeners();
  }
}