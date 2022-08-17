//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/friend/addFriend_model.dart';
import 'package:capstone_project/models/friend/checkFriend_model.dart';
import 'package:capstone_project/models/friend/delFriend_model.dart';
import 'package:capstone_project/models/friend/selectFriend_model.dart';
import 'package:capstone_project/services/api_service.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();
  bool isApiCallProcess = false;

  late CheckFriendRequestModel checkFriendRequestModel;
  late AddFriendRequestModel addFriendRequestModel; // add friend
  late DeleteFriendRequestModel deleteFriendRequestModel; // delete friend
  late SelectFriendRequestModel selectFriendRequestModel; // list friend

  @override
  void initState() {
    super.initState();
    selectFriendRequestModel = SelectFriendRequestModel(
      uID1: 9, // FIXME 0815 : catch user's UID
    );
    checkFriendRequestModel = CheckFriendRequestModel(
      uID1: 9, 
      uID2: int.parse(''),
      // uID2: 10
    );
    addFriendRequestModel = AddFriendRequestModel(
      uID1: 9, // FIXME 0815 : catch user's UID
      // uID2: int.parse(''),
      uID2: 10
    );
    deleteFriendRequestModel = DeleteFriendRequestModel(
      uID1: 9, // FIXME 0815 : catch user's UID
      // uID2: int.parse('')
      uID2:10
    );
    
  }

  int currentItem = 1;
  APIService apiservice = new APIService();
  // final Future<SelectFriendResponseModel> friendList = apiservice.selectFriend(selRequestModel);
  final friendList = [
    {'id': 1, 'name': 'test1'}, {'id': 2, 'name': 'test2'}, {'id': 3, 'name': 'test3'},
    {'id': 4, 'name': 'test4'}, {'id': 5, 'name': 'test5'}, {'id': 6, 'name': 'test6'},
    {'id': 7, 'name': 'test7'}, {'id': 8, 'name': 'test8'}, {'id': 9, 'name': 'test9'},
    {'id': 10, 'name': 'test10'}, {'id': 11, 'name': 'test11'}, {'id': 12, 'name': 'test12'},
    {'id': 13, 'name': 'test13'}, {'id': 14, 'name': 'test14'}, {'id': 15, 'name': 'test15'},
  ];
  List<Widget> _listView(context){
    List<Widget> listWidget = [];
    friendList.map((e) => {
      listWidget.add(listItem(e))
    }).toList();
    return listWidget;
  }
  Widget listItem(item){
    final bool alreadySaved = currentItem == item['id'];
    return ListTile(
      title: Text(
        item['name'],
        style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: PrimaryMiddleGreen,
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Container(
                  height: height * 0.08,
                  width: width,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(7),
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
                      children: 
                      _listView(context),
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
                        showSearchInput(context);
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

  Future<void> showSearchInput(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible:true, // can click outspace to close the box
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: PrimaryLightYellow,
          title: Text('新增好友'),
          content: TextFormField( // input(search) friend's ID
            keyboardType: TextInputType.number, 
            onSaved: (input) => checkFriendRequestModel.uID2 = input! as int,
            validator: (input) => input!.contains(RegExp(r"^\+?0[0-9]{10}$"))
              ? "Friend's ID should composed of number" 
              : null,
            // check if account contains @
            decoration: new InputDecoration(
              hintText: "@ Your Friend's ID",
              // prefixIcon: Icon(Icons.person),
              labelText: "Friend ID",
            ), 
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('取消'), 
              onPressed: () {
                Navigator.of(context).pop(FriendPage());
              },
            ),
            FlatButton(
              child: Text('確定'),
              onPressed: () {
                setState(() { // show waiting signal while click accept btn
                  isApiCallProcess = true;
                });
                APIService apiService = new APIService();
                // 1. checkFriend
                apiService.checkFriend(checkFriendRequestModel).then((value) {
                  if (value){
                    setState(() {
                      isApiCallProcess = false;
                    });
                    print('You have send a friend invitation to' + checkFriendRequestModel.uID2.toString());
                    Navigator.of(context).pop(FriendPage());
                    // FIXME 0816 : 2. send socket to UID2
                  } else {
                    print("You and" + checkFriendRequestModel.uID2.toString() + "are friends already!");
                  }
                },);
                // 3. if UID2 accept inviation => call addFriend
              },
            )
          ],
        );
      },
    );
  }
}
