import 'package:capstone_project/models/friend/insertFriend_model.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/services/stream_socket.dart';
import 'package:capstone_project/size_config.dart';
import 'package:flutter/material.dart';
// basic setting
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/default_icons.dart';
// service
import 'package:capstone_project/services/http_service.dart';
// model
import 'package:fluttertoast/fluttertoast.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  APIService apiService = APIService();
  StreamSocket streamSocket = StreamSocket();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  late InsertFriendRequestModel requestModel = InsertFriendRequestModel(uID1: UserData.uid.toString(), account: "");
  bool isApiCallProcess = false;
  late List<Map<String, dynamic>>? noteList = [];
  String userName = UserData.userName;
  String userAccount = UserData.userAccount;
  int counter = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: defaultBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.noteBarHeight!,
              left: getProportionateScreenWidth(0.03),
              right: getProportionateScreenWidth(0.03),
              bottom: getProportionateScreenHeight(0.05)
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    DefNotificationIcon(enable: false),
                    const DefSettingIcon(enable: true,),
                  ],
                ),
                Expanded(
                  child: FutureBuilder(
                    future: getNotificationList(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListView.separated(
                          itemCount: noteList!.length,
                          itemBuilder: (buildContext, index){
                            // 右滑刪除
                            // return Dismissible(
                            //   // Each Dismissible must contain a Key. Keys allow Flutter to uniquely identify widgets.
                            //   key: UniqueKey(),
                            //   // Provide a function that tells the app
                            //   // what to do after an item has been swiped away.
                            //   onDismissed: (direction) {
                            //     setState(() {
                            //       SqliteHelper.delete(
                            //         tableName: "notification",
                            //         tableIdName: "nID",
                            //         deleteId: noteList![index]["nID"]
                            //       );
                            //     });
                            //     Navigator.of(context).pop(const NotificationPage());
                            //     Fluttertoast.showToast(msg: "已刪除一項通知");
                            //   },
                            //   background: Container(color: darkGreen2,), // Show a background color as the item is swiped away.
                            //   child: 
                            return ListTile(
                              title: Text(
                                noteList![index]["info"],
                                style: const TextStyle(color: darkGreen2, fontWeight: FontWeight.bold),
                              ),
                              tileColor: unselectedColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onTap: () {
                                if(noteList![index]["ctlmsg"] == "friend request") {
                                  showResponseAlert(context, noteList![index]["nID"], noteList![index]["account_msg"]);
                                }
                                // setState(() {});
                              },
                              trailing: IconButton(
                                icon: const ImageIcon(deleteIcon),
                                color: grassGreen,
                                onPressed: () {
                                  SqliteHelper.delete(
                                    tableName: "notification",
                                    tableIdName: "nID",
                                    deleteId: noteList![index]["nID"]
                                  );
                                  setState(() {});
                                },
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                            const VerticalSpacing(percent: 0.01,)
                        );
                      } else {
                        print("抓資料中");
                        return const Text("抓資料中");
                      }
                    })
                )
              ]
            ),
          )
      )
    );
  }

  Future<List<Map<String, dynamic>>?> getNotificationList() async {
    isApiCallProcess = true;
    noteList = await SqliteHelper.queryAll(tableName: "notification");
    isApiCallProcess = false;
    print('======\nnotificationList $noteList\n======');
    return noteList;
  }


  Future<void> showResponseAlert(BuildContext context,int nID, String who) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkGreen2,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
          title: const Text(
            '好友邀請',
            style: TextStyle(color: unselectedColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '@$who 想成為你的好友',
            style: TextStyle(color: unselectedColor, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(unselectedColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: const Text(
                '拒絕',
                style: TextStyle(color: darkGreen2),
              ),
              onPressed: () {
                // 拒絕時不須呼叫、不須進後端修改 friend table status
                setState(() {
                  SqliteHelper.delete(tableName: "notification", tableIdName: "nID", deleteId: nID);
                  setState(() {});
                  Navigator.of(context).pop();
                });
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(unselectedColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: const Text(
                '接受',
                style: TextStyle(color: darkGreen2),
              ),
              onPressed: () {
                // show waiting signal while click accept btn
                isApiCallProcess = true;
                requestModel.account = who;
                print("=====\n INSERT FRIEND REQUEST ：${requestModel.toString()}\n======");
                apiService.insertFriend(requestModel).then((value) {
                  if (value) {
                    isApiCallProcess = false;
                    streamSocket.friendResponse(who);
                    SqliteHelper.delete(tableName: "notification", tableIdName: "nID", deleteId: nID);
                    setState(() { });
                    Navigator.of(context).pop(const NotificationPage());
                    Fluttertoast.showToast(msg: 'You Accepted a Friend');
                  } else {
                    Fluttertoast.showToast(msg: "Accept Friend Invitation Failed");
                  }
                },);
              },
            ),
          ],
        );
      },
    );
  }

}
