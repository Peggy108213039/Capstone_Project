//import 'dart:html';
import 'package:capstone_project/components/loadingAnimation.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/size_config.dart';
import 'package:capstone_project/ui/friend/searchFriend_page.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';

import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/models/friend/addFriend_model.dart';
import 'package:capstone_project/models/friend/deleteFriend_model.dart';
import 'package:capstone_project/models/friend/selectFriend_model.dart';
import 'package:capstone_project/models/friend/checkFriend_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  APIService apiService = APIService();
  bool isApiCallProcess = false;
  SelectFriendRequestModel selectFriendRequestModel =
      SelectFriendRequestModel(uID1: UserData.uid.toString());
  late DeleteFriendRequestModel delRequestModel =
      DeleteFriendRequestModel(uID1: UserData.uid.toString(), uID2: "");
  late AddFriendRequestModel addFriendRequestModel =
      AddFriendRequestModel(uID1: UserData.uid.toString(), account: "");
  late List<Map<String, dynamic>>? friendList;

  @override
  void initState() {
    // var _pageData = SqliteHelper.queryAll(tableName: "friend") as List<String>;
    // _getListData().then((data) => setState(() {
    //   _pageData = data;
    // }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double? width = SizeConfig.screenWidth;
    double? height = SizeConfig.screenHeight;

    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: defaultBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: transparentColor,
        //appBar: AppBar(title: Text("Base Stateful Demo")),
        body: Padding(
          padding: EdgeInsets.only(
            top: SizeConfig.noteBarHeight!,
            left: getProportionateScreenWidth(0.03),
            right: getProportionateScreenWidth(0.03),
          ),
          child: Column(children: <Widget>[
            Container(
              height: height! * 0.1,
              width: width,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(7),
              child: const Text(
                '我的好友',
                style: TextStyle(
                    color: darkGreen2,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //     IconButton( // notification icon
            //       icon: Icon(Icons.edit_outlined),
            //       color: PrimaryLightYellow,
            //       // size: 30.0,
            //       onPressed: () {
            //         Navigator.push( context,
            //           MaterialPageRoute(
            //             builder: (context) => const SearchFriendPage(),
            //           ),
            //         );
            //       },
            //     )
            //   ],
            // ),
            Expanded(
                child: SingleChildScrollView(
              child: FutureBuilder(
                future: getFriendList(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: friendList!.length,
                      itemBuilder: (buildContext, index) {
                        return ListTile(
                          title: Text(friendList![index]["account"]),
                          textColor: darkGreen1,
                          enableFeedback: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel),
                            color: darkGreen1,
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
                  } else {
                    print("資料未抓到");
                    return const Text("資料未抓到");
                    // print("動畫");
                    // return LoadingAnimation(child: build(context), inAsyncCall: inApiCallProcess);
                  }
                },
              ),
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  // notification icon
                  icon: const Icon(Icons.add_circle_outlined),
                  iconSize: 30,
                  color: PrimaryLightYellow,
                  onPressed: () {
                    showAddFriendAlert(context);
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
            const VerticalSpacing(
              percent: 0.01,
            )
          ]),
        ),
      ),
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
                setState(() {
                  // show waiting signal while click accept btn
                  isApiCallProcess = true;
                  delRequestModel.uID2 = friendList![index]["uID"].toString();
                });
                print("確定刪除好友");
                apiService.deleleFriend(delRequestModel).then(
                  (value) {
                    if (value) {
                      setState(() {
                        isApiCallProcess = false;
                      });
                      apiService.selectFriend(selectFriendRequestModel);
                      Navigator.pop(context);
                      print('已刪除好友 - $deleteFriendAccount');
                    } else {
                      print("刪除好友失敗");
                    }
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showAddFriendAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: PrimaryLightYellow,
          title: const Text('新增好友'),
          content: Form(
            key: globalFormKey,
            child: TextFormField(
              keyboardType: TextInputType.name,
              validator: (input) {
                if (input!.isEmpty ||
                    !RegExp(r'^[a-z0-9_-]{3,15}$').hasMatch(input)) {
                  return "account should be valid";
                } else {
                  return null;
                }
              },
              onSaved: (input) => addFriendRequestModel.account = input!,
              decoration: const InputDecoration(
                hintText: "輸入好友帳號",
                prefixIcon: Icon(Icons.people),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                print('【取消】新增好友');
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('邀請'),
              onPressed: () {
                if (validateAndSave(globalFormKey)) {
                  setState(() {
                    isApiCallProcess = true;
                  });
                  apiService.addFriend(addFriendRequestModel).then((value) {
                    if (value) {
                      setState(() {
                        isApiCallProcess = false;
                      });
                      Navigator.pop(context);
                      print("【成功】新增好友");
                    } else {
                      print("【失敗】新增好友");
                      setState(() {
                        isApiCallProcess = false;
                      });
                      Fluttertoast.showToast(msg: "送出交友邀請失敗");
                      Navigator.pop(context);
                    }
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool validateAndSave(inputKey) {
    final form = inputKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
