// 用 FutureBuilder 的版本

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
import 'package:http/http.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  APIService apiService = APIService();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isApiCallProcess = false;

  late CheckFriendRequestModel checkRequestModel;
  late AddFriendRequestModel addRequestModel; // add friend
  late DeleteFriendRequestModel deleteRequestModel; // delete friend
  late SelectFriendRequestModel selectRequestModel; // list friend

  late List<Map<String, dynamic>>? friendList;

  @override
  void initState() {
    // super.initState();
    // selectRequestModel = SelectFriendRequestModel(uID1: UserData.uid.toString());
    // checkFriendRequestModel = CheckFriendRequestModel(
    //   uID1: UserData.uid, 
    //   uID2: int.parse(''),
    //   // uID2: 10
    // );
    // addFriendRequestModel = AddFriendRequestModel(
    //   uID1: UserData.uid,
    //   // uID2: int.parse(''),
    //   uID2: 10
    // );
    // deleteFriendRequestModel = DeleteFriendRequestModel(
    //   uID1: UserData.uid,
    //   // uID2: int.parse('')
    //   uID2:10
    // );
    // SqliteHelper.initDatabase();
    // APIService apiservice = APIService();
    // await apiservice.selectFriend(selectRequestModel);
    // print(SqliteHelper.queryAll(tableName: "friend"));
    // print("印完我的 Friend Tableㄌ");
  }

  @override
  Widget build(BuildContext context) {
     print('FRIEND PAGE BUILD');
    int currentItem = 1;
    // friendList = SqliteHelper.queryAll(tableName: "friend");
    // final friendList = [
    //   {'id': 1, 'name': 'test1'}, {'id': 2, 'name': 'test2'}, {'id': 3, 'name': 'test3'},
    //   {'id': 4, 'name': 'test4'}, {'id': 5, 'name': 'test5'}, {'id': 6, 'name': 'test6'},
    //   {'id': 7, 'name': 'test7'}, {'id': 8, 'name': 'test8'}, {'id': 9, 'name': 'test9'},
    //   {'id': 10, 'name': 'test10'}, {'id': 11, 'name': 'test11'}, {'id': 12, 'name': 'test12'},
    //   {'id': 13, 'name': 'test13'}, {'id': 14, 'name': 'test14'}, {'id': 15, 'name': 'test15'},
    // ];
    // List<Widget> _listView(context){
    //   List<Widget> listWidget = [];
    //   friendList.map((e) => {
    //     listWidget.add(friendList(e))
    //   }).toList();
    //   return listWidget;
    // }

    double? width = SizeConfig.screenWidth;
    double? height = SizeConfig.screenHeight;
    return Stack(children: [
      Container(
        height: height! * 0.08,
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
      Scaffold(
        backgroundColor: PrimaryMiddleGreen,
        body: FutureBuilder(
          future: getFriendList(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(snapshot.hasData) {
              var response = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column( children: <Widget>[
                  Expanded( child: SingleChildScrollView(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: friendList!.length,
                      itemBuilder: (buildContext, index) {
                        return Column(
                          children: [ ListTile(
                            title: friendList![index]['uID'],
                            textColor: PrimaryLightYellow,
                            enableFeedback: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.cancel_outlined),
                              color: PrimaryMiddleYellow,
                              onPressed: () { 
                                print('【按下】刪除好友');
                                showDeleteFriendAlert(context);
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const FriendPage(),
                                //   ),
                                // );
                              },
                            ),
                            onLongPress: () {
                              print("我按下了" + index.toString() + "號好友");
                            },
                          )],
                        );
                      }, 
                    ),
                // child: Column(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [Text('${response[0]['uID']}')],
                //   // _listView(context),
                // )
                  ),),
              
                ]),
              );
            } else{
              print('資料未抓到');
              return const Text('資料未抓到');
              // print('動畫');
              // return LoadingAnimation(child: build(context), inAsyncCall: isApiCallProcess);
            }
          },
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment:CrossAxisAlignment.center,
        children: <Widget>[
          IconButton( // notification icon
            icon: const Icon(Icons.add_circle_outlined),
            color: PrimaryLightYellow,
            // size: 30.0,
            onPressed: (){
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => const SearchFriendPage(),
                ),
              );
            },
          )
        ],
      ),
    ],);
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

  Future<void> showDeleteFriendAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: PrimaryLightYellow,
          title: const Text('確認刪除好友'),
          content: const Text('是否確定刪除 Uncle 好友？'),
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
                });
                apiService.deleleFriend(deleteRequestModel).then((value) {
                  if (value){
                    setState(() {
                      isApiCallProcess = false;
                    });
                    Navigator.of(context).pop(const FriendPage());
                    print('已刪除好友 - Uncle');
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

  // Future<void> showSearchInput(BuildContext context) {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible:true, // can click outspace to close the box
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: PrimaryLightYellow,
  //         title: const Text('新增好友'),
  //         content: TextFormField( // input(search) friend's ID
  //           keyboardType: TextInputType.number, 
  //           onSaved: (input) => checkFriendRequestModel.uID2 = input! as int,
  //           validator: (input) => input!.contains(RegExp(r"^\+?0[0-9]{10}$"))
  //             ? "Friend's ID should composed of number" 
  //             : null,
  //           // check if account contains @
  //           decoration:const InputDecoration(
  //             hintText: "@ Your Friend's ID",
  //             // prefixIcon: Icon(Icons.person),
  //             labelText: "Friend ID",
  //           ), 
  //         ),
  //         actions: <Widget>[
  //           FlatButton(
  //             child: const Text('取消'), 
  //             onPressed: () {
  //               Navigator.of(context).pop(FriendPage());
  //             },
  //           ),
  //           FlatButton(
  //             child: const Text('確定'),
  //             onPressed: () {
  //               setState(() { // show waiting signal while click accept btn
  //                 isApiCallProcess = true;
  //               });
  //               APIService apiService = APIService();
  //               // 1. checkFriend
  //               apiService.checkFriend(checkFriendRequestModel).then((value) {
  //                 if (value){
  //                   setState(() {
  //                     isApiCallProcess = false;
  //                   });
  //                   print('You have send a friend invitation to' + checkFriendRequestModel.uID2.toString());
  //                   Navigator.of(context).pop(const FriendPage());
  //                   // FIXME 0816 : 2. send socket to UID2
  //                 } else {
  //                   print("You and" + checkFriendRequestModel.uID2.toString() + "are friends already!");
  //                 }
  //               },);
  //               // 3. if UID2 accept inviation => call addFriend
  //             },
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }
}
