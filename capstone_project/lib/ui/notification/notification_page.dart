import 'package:capstone_project/services/socket_service.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
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
  String userName = UserData.userName;
  String userAccount = UserData.userAccount;
  late List<Map<String, dynamic>>? notificationList; // 通知列表

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingAnimation(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
    );
  }

  Widget _uiSetup(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: defaultBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (width * 0.035), vertical: (height * 0.05)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    DefNotificationIcon(enable: false),
                    DefSettingIcon(enable: true),
                  ],
                ),
                Container(
                  // 使用者 info Box
                  decoration: BoxDecoration(
                      border: Border.all(color: PrimaryLightYellow, width: 3)),
                  height: height * 0.15, // container
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Container
                      double innerHeight = constraints.maxHeight;
                      double innerWidth = constraints.maxWidth;
                      // Stack
                      return InfoBox(
                        innerHeight: innerHeight,
                        innerWidth: innerWidth,
                        visible: false,
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: (height * 0),
                ),
                // notification list
                Expanded(child: SingleChildScrollView(child: FutureBuilder(
                  future: getNotificationList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if(snapshot.hasData) {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: notificationList!.length,
                        itemBuilder: (buildContext, index){
                          return ListTile(
                            title: Text(notificationList![index]['account ']),
                            textColor: PrimaryLightYellow,
                            onLongPress: () {
                              print("我按下了" + index.toString() + "號通知");
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
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<List<Map<String, dynamic>>?> getNotificationList() async {
    isApiCallProcess = true;
    notificationList = await SqliteHelper.queryAll(tableName: "friend");
    isApiCallProcess = false;
    print('======\n NOTIFICATION LIST \n $notificationList\n======');
    return notificationList;
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
