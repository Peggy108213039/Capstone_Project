import 'package:capstone_project/services/socket_service.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/services/stream_socket.dart';
import 'package:capstone_project/size_config.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/components/infoBox.dart';
// basic setting
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/loadingAnimation.dart';
import 'package:capstone_project/components/default_icons.dart';
// service
import 'package:capstone_project/services/http_service.dart';
// model
import 'package:capstone_project/models/friend/checkFriend_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  SocketService socketService = SocketService();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  late CheckFriendRequestModel requestModel;
  bool isApiCallProcess = false;
  late List<Map<String, dynamic>>? notificationList;
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
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    DefNotificationIcon(enable: false),
                    DefSettingIcon(enable: true,),
                  ],
                ),
                Expanded(child: SingleChildScrollView(child: FutureBuilder(
                  future: getNotificationList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if(snapshot.hasData) {
                      return ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: notificationList!.length,
                        itemBuilder: (buildContext, index){
                          final item = notificationList?[index];
                          return Dismissible(
                            // Each Dismissible must contain a Key. Keys allow Flutter to uniquely identify widgets.
                            key: Key(notificationList![index]["account"]),
                            // Provide a function that tells the app
                            // what to do after an item has been swiped away.
                            onDismissed: (direction) {
                              setState(() {
                                //notificationList?.removeAt(index);
                                // 並進 sqlite 中將此通知刪除
                              });
                              // Then show a snackbar.
                              Fluttertoast.showToast(msg: "已刪除一項通知");
                            },
                            // Show a red background as the item is swiped away.
                            // 列表项被滑出时，显示一个红色背景(Show a red background as the item is swiped away)
                            background: Container(color: darkGreen2,),
                            child: ListTile(
                              title: Text(
                                notificationList![index]["account"],
                                style: const TextStyle(color: darkGreen2),
                              ),
                              tileColor: unselectedColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                          // return ListTile(
                          // );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                          const VerticalSpacing(percent: 0.01,)
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
      )
    );
  }

  Future<List<Map<String, dynamic>>?> getNotificationList() async {
  isApiCallProcess = true;
  notificationList = await SqliteHelper.queryAll(tableName: "friend");
  isApiCallProcess = false;
  print('======\nfriendList $notificationList\n======');
  return notificationList;
  // return Future.delayed(const Duration(seconds: 1), () {
  // });
  }


  Future<void> showAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: PrimaryLightYellow,
          title: const Text('確認好友邀請'),
          content: Text('確定接受來自 @' + userAccount + '的交友邀請'),
          actions: <Widget>[
            TextButton(
              child: const Text('拒絕'),
              onPressed: () {
                print('You Denied Nobody');
                Navigator.of(context).pop(NotificationPage());
              },
            ),
            TextButton(
              child: const Text('接受'),
              onPressed: () {
                setState(() {
                  // show waiting signal while click accept btn
                  isApiCallProcess = true;
                });
                APIService apiService = APIService();
                apiService.checkFriend(requestModel).then(
                  (value) {
                    if (value) {
                      setState(() {
                        isApiCallProcess = false;
                      });
                      Navigator.of(context).pop(NotificationPage());
                      print('You Accepted a Friend');
                    } else {
                      print("Accept Friend Invitation Failed");
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
}
