//import 'dart:html';
import 'dart:ui';

import 'package:capstone_project/models/friend/inviteFriend_model.dart';
import 'package:capstone_project/services/stream_socket.dart';
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
  StreamSocket streamSocket = StreamSocket();
  bool isApiCallProcess = false ;
  SelectFriendRequestModel selectFriendRequestModel = SelectFriendRequestModel(uID1: UserData.uid.toString());
  late CheckFriendRequestModel checkRequestModel = CheckFriendRequestModel(uID1: UserData.uid.toString(), friendAccount: "");
  late InviteFriendRequestModel inviteRequestModel = InviteFriendRequestModel(uID1: UserData.uid.toString(), friendAccount: "");
  late DeleteFriendRequestModel delRequestModel = DeleteFriendRequestModel(uID1: UserData.uid.toString(), uID2: "");
  late List<Map<String, dynamic>>? friendList;
  late var friendAccount = '';

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Scaffold(
        backgroundColor: activityGreen,
        appBar: AppBar(
          backgroundColor: grassGreen,
          title: const Center(
              child: Text(
            '好友清單',
          )),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          actions: [
            ElevatedButton(
              child: const ImageIcon(addIcon),
              onPressed: () {searchNewFriendAlert(context);},
              style: ElevatedButton.styleFrom(
                backgroundColor: transparentColor,
                shadowColor: transparentColor),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Expanded(child: SingleChildScrollView(
                padding: EdgeInsets.all(8),
                child: FutureBuilder(
                future: getFriendList(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.hasData) {
                    return ListView.builder(
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: friendList!.length,
                      itemBuilder: (buildContext, index){
                        return ListTile(
                          title: Text(
                            friendList![index]["account"],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          subtitle: Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              friendList![index]["name"],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          textColor: grassGreen,
                          enableFeedback: true,
                          trailing: IconButton(
                            icon: const ImageIcon(deleteIcon),
                            color: unselectedColor,
                            onPressed: () { 
                              showDeleteFriendAlert(context, index);
                            },
                          ),
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
            ]
          ),
        )
      ),
    );
  }

  Future<List<Map<String, dynamic>>?> getFriendList() async {
    isApiCallProcess = true;
    await apiService.selectFriend(SelectFriendRequestModel(uID1: UserData.uid.toString()));
    friendList = await SqliteHelper.queryAll(tableName: "friend");
    isApiCallProcess = false;
    print('======\nfriendList $friendList\n======');
    return friendList;
    // return Future.delayed(const Duration(seconds: 1), () {
    // });
  }

  Future<void> showDeleteFriendAlert(BuildContext context, index) {
    var deleteFriendAccount = friendList![index]["account"];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: middleGreen,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
          title: const Text(
            '確認刪除好友',
            style: TextStyle(color: unselectedColor),
          ),
          content: Text(
            '是否確定刪除 $deleteFriendAccount 好友？',
            style: const TextStyle(color: unselectedColor),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(unselectedColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: const Text(
                '取消',
                style: TextStyle(color: middleGreen),
              ), 
              onPressed: () {
                Navigator.of(context);
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(unselectedColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: const Text(
                '確定',
                style: TextStyle(color: middleGreen),
              ),
              onPressed: () {
                setState(() { // show waiting signal while click accept btn
                  isApiCallProcess = true;
                  delRequestModel.uID2 = friendList![index]["uID"].toString();
                });
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
          backgroundColor: middleGreen,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
          title: const Text(
            '請輸入好友帳號',
            style: TextStyle(color: unselectedColor),
          ),
          content: TextFormField( // input(search) friend's ID
            style: const TextStyle(color: unselectedColor),
            keyboardType: TextInputType.text, 
            onSaved: (input) => checkRequestModel.friendAccount = input!,
            validator: (input) => input!.length < 4 ? "帳號長度需大於 5 個字元" : null,
            decoration:const InputDecoration(
              // hintText: "@ Your Friend's Account",
                prefixIcon: Icon(Icons.person, color: unselectedColor,),
                enabledBorder: UnderlineInputBorder(      
                  borderSide: BorderSide(color: unselectedColor),   
                ),  
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: lightGreen0),
                ), 
                focusColor: unselectedColor
            ), 
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(unselectedColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: const Text(
                '取消',
                style: TextStyle(color: middleGreen),
              ), 
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(unselectedColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: const Text(
                '加朋友',
                style: TextStyle(color: middleGreen),
              ),
              onPressed: () {
                APIService apiService = APIService();
                apiService.checkFriend(checkRequestModel).then((value) {
                  if(value){
                    inviteRequestModel.friendAccount = checkRequestModel.friendAccount;
                    apiService.inviteFriend(inviteRequestModel).then((value) {
                      if(value) {
                        Fluttertoast.showToast(msg: "成功發出好友邀請");
                        streamSocket.friendRequest(inviteRequestModel.friendAccount);
                      }
                    });
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
