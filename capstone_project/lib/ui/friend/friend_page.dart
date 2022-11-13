//import 'dart:html';
import 'package:capstone_project/services/socket_service.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/size_config.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';

import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/models/friend/deleteFriend_model.dart';
import 'package:capstone_project/models/friend/selectFriend_model.dart';
import 'package:capstone_project/models/friend/checkFriend_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  APIService apiService = APIService();
  bool isApiCallProcess = false ;
  SelectFriendRequestModel selectFriendRequestModel = SelectFriendRequestModel(uID1: UserData.uid.toString());
  late CheckFriendRequestModel checkRequestModel = CheckFriendRequestModel(uID1: UserData.uid.toString(), friendAccount: "");
  late DeleteFriendRequestModel delRequestModel = DeleteFriendRequestModel(uID1: UserData.uid.toString(), uID2: "");
  late List<Map<String, dynamic>>? friendList;
  late var friendAccount = '';

  // @override
  // Future<void> initState() async {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    
    return Stack(
      children: [
        Scaffold(
          backgroundColor: PrimaryMiddleGreen,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Container(
                  height: height * 0.08,
                  width: width,
                  alignment: Alignment.center,
                  padding:const  EdgeInsets.all(7),
                  child: const Text(
                    '我的好友',
                    style: TextStyle(
                      color: PrimaryLightYellow,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon( // edit Friend icon
                      Icons.edit_outlined,
                      color: PrimaryLightYellow,
                      size: 30.0,
                    )
                  ],
                ),
                Expanded(child: SingleChildScrollView(child: FutureBuilder(
                  future: getFriendList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if(snapshot.hasData) {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: friendList!.length,
                        itemBuilder: (buildContext, index){
                          return ListTile(
                            title: Text(friendList![index]["account"]),
                            textColor: PrimaryLightYellow,
                            enableFeedback: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: PrimaryMiddleYellow,
                              onPressed: () { 
                                print('【按下】刪除好友');
                                showDeleteFriendAlert(context, index);
                              },
                            ),
                            onLongPress: () {
                              print("我按下了" + index.toString() + "號好友");
                            },
                          );
                        },
                      );
                    } else{
                      print("抓資料中");
                      return const Text("抓資料中");
                      // return LoadingAnimation(child: build(context), inAsyncCall: isApiCallProcess);
                    }
                  },
                ),)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton( // notification icon
                      icon: const Icon(Icons.add_circle_outlined),
                      iconSize: 30,
                      color: PrimaryLightYellow,
                      onPressed: () {
                        searchNewFriendAlert(context);
                        // 較簡單的搜尋 alertBox
                        // 較精美的搜尋頁面
                        // Navigator.push( context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const SearchFriendPage(),
                        //   ),
                        // );
                      },
                    )
                  ],
                ),
              ]
            ),
          )
        )
      ],
    );
  }

  Future<List<Map<String, dynamic>>?> getFriendList() async {
    isApiCallProcess = true;
    friendList = await SqliteHelper.queryAll(tableName: "friend");
    isApiCallProcess = false;
    print('======\nfriendList $friendList\n======');
    return friendList;
    // return Future.delayed(const Duration(seconds: 1), () {
    // });
  }

  Future<List<String>> _getListData() async {
    await Future.delayed(const Duration(seconds: 3));
    return List<String>.generate(10, (index) => "$index content");
  }

  Future<void> showDeleteFriendAlert(BuildContext context, index) {
    var deleteFriendAccount = friendList![index]["account"];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: PrimaryLightYellow,
          title: const Text('確認刪除好友'),
          content: Text('是否確定刪除 $deleteFriendAccount 好友？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'), 
              onPressed: () {
                print('已取消動作 - 刪除好友');
                Navigator.of(context).pop(const FriendPage());
              },
            ),
            TextButton(
              child: const Text('確定'),
              onPressed: () {
                setState(() { // show waiting signal while click accept btn
                  isApiCallProcess = true;
                  delRequestModel.uID2 = friendList![index]["uID"].toString();
                });
                print("確定刪除好友");
                apiService.deleleFriend(delRequestModel).then((value) {
                  if (value){
                    setState(() {
                      isApiCallProcess = false;
                    });
                    SqliteHelper.delete(tableName: "friend", tableIdName: "uID", deleteId: int.parse(delRequestModel.uID2));
                    Navigator.pop(context);
                    print('已刪除好友 - $deleteFriendAccount');
                  } else {
                    print("刪除好友失敗");
                  }
                },);
              },
            ),
          ],
        );
      },
    );
  }

    Future<void> searchNewFriendAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible:true, // can click outspace to close the box
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: PrimaryLightYellow,
          title: const Text('新增好友'),
          content: TextFormField( // input(search) friend's ID
            keyboardType: TextInputType.text, 
            onSaved: (input) => checkRequestModel.friendAccount = input!,
            validator: (input) => input!.length < 4 ? "帳號長度需大於 5 個字元" : null,
            // check if account contains @
            decoration:const InputDecoration(
              hintText: "@ Your Friend's Account",
              prefixIcon: Icon(Icons.person),
            ), 
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'), 
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('加朋友'),
              onPressed: () {
                // FIXME 1113：需要先 checkFriend
                APIService apiService = APIService();
                apiService.checkFriend(checkRequestModel).then((value) {
                  if(value){
                    print(checkRequestModel.friendAccount);
                    SocketService socketService = SocketService();
                    //socketService.friendRequest(checkRequestModel.friendAccount);
                    socketService.joinAccountRoom();
                    Navigator.pop(context);
                  } else {
                    Fluttertoast.showToast(msg: "無法新增該名好友（已為好友關係 / 已發送過邀請）");                    
                  }
                });
              },
            )
          ],
        );
      },
    );
  }

  bool validateAndSave(inputKey) {
    final form = inputKey.currentState;
    if(form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
