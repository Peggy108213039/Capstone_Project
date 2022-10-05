//import 'dart:html';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/ui/friend/searchFriend_page.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';

import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/models/friend/addFriend_model.dart';
import 'package:capstone_project/models/friend/deleteFriend_model.dart';
import 'package:capstone_project/models/friend/selectFriend_model.dart';
import 'package:capstone_project/models/friend/checkFriend_model.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool isApiCallProcess = false;

  late CheckFriendRequestModel checkRequestModel;
  late AddFriendRequestModel addRequestModel; // add friend
  late DeleteFriendRequestModel deleteRequestModel; // delete friend
  late SelectFriendRequestModel selectRequestModel; // list friend

  @override
  Future<void> initState() async {
    super.initState();
    selectRequestModel = SelectFriendRequestModel(uID1: UserData.uid.toString());
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
    SqliteHelper.initDatabase();
    APIService apiservice = APIService();
    await apiservice.selectFriend(selectRequestModel);
    print(SqliteHelper.queryAll(tableName: "friend"));
    print("印完我的 Friend Tableㄌ");
  }

  @override
  Widget build(BuildContext context) {
      int currentItem = 1;
  // final Future<List> friendList = apiservice.selectFriend(selectRequestModel);
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
  Widget listItem(item){
    final bool alreadySaved = currentItem == item['id'];
    return ListTile(
      title: Text(
        item['name'],
        style: const TextStyle(
          color: PrimaryLightYellow,
          fontSize: 20,
        ),
      ),
      /*onTap: () {
        setState(() {
          currentItem = item['id'];
        });
      },*/
    );
  }

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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      // children: 
                      // _listView(context),
                    )
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
                        Navigator.push( context,
                          MaterialPageRoute(
                            builder: (context) => const SearchFriendPage(),
                          ),
                        );
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
