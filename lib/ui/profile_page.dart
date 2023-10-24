import 'dart:ui';

import 'package:capstone_project/models/userInfo/getInfo.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/services/stream_socket.dart';
import 'package:capstone_project/size_config.dart';
import 'package:flutter/material.dart';
// basic setting
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/default_icons.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageOneState();
}

class _ProfilePageOneState extends State<ProfilePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  APIService apiService = APIService();
  late getInfoRequestModel requestModel =
      getInfoRequestModel(uID: UserData.uid.toString());
  late List<Map<String, dynamic>>? noteList = [];
  late bool showBadge = false;

  String userName = ''; // catch & print userinfo table
  String userAccount = '';
  String accDistance = '';
  String accTrack = '';
  String accActivity = '';

  @override
  void initState() {
    StreamSocket.loginSend();
    super.initState();
    getMyInfo();
    userName = UserData.userName.toString(); // catch & print userinfo table
    userAccount = UserData.userAccount;
    accDistance = (UserData.totalDistance / 1000).toString();
    accTrack = UserData.totalTrack.toString();
    accActivity = UserData.totalActivity.toString();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
                horizontal: (SizeConfig.screenWidth! * 0.035),
                vertical: (SizeConfig.screenHeight! * 0.05)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, SizeConfig.screenHeight! * 0.1,
                      0, SizeConfig.screenHeight! * 0.02),
                  width: SizeConfig.screenHeight! * 0.3,
                  height: SizeConfig.screenHeight! * 0.3,
                  decoration: BoxDecoration(
                      color: transparentColor,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                          fit: BoxFit.fill, image: defaultUserImage)),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      0,
                      SizeConfig.screenHeight! * 0.01,
                      0,
                      SizeConfig.screenHeight! * 0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        // 使用者名稱
                        userName,
                        style: const TextStyle(
                          color: darkGreen2,
                          fontSize: 35.0,
                        ),
                      ),
                      SizedBox(
                        height: (SizeConfig.screenHeight! * 0.005),
                      ),
                      Text(
                        "@$userAccount",
                        style: const TextStyle(color: darkGreen2, fontSize: 25),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      0,
                      SizeConfig.screenHeight! * 0.01,
                      0,
                      SizeConfig.screenHeight! * 0.01),
                  padding: EdgeInsets.fromLTRB(
                      0,
                      SizeConfig.screenHeight! * 0.02,
                      0,
                      SizeConfig.screenHeight! * 0.02),
                  width: SizeConfig.screenWidth! * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.elliptical(
                            SizeConfig.screenWidth! * 0.1,
                            SizeConfig.screenHeight! * 0.5 * 0.1),
                        bottomRight: Radius.elliptical(
                            SizeConfig.screenWidth! * 0.1,
                            SizeConfig.screenHeight! * 0.5 * 0.1),
                        topRight: const Radius.circular(10.0),
                        bottomLeft: const Radius.circular(10.0)),
                    color: semiTransparentColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "累積紀錄",
                        style: TextStyle(color: darkGreen2, fontSize: 22),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0,
                            SizeConfig.screenHeight! * 0.01,
                            0,
                            SizeConfig.screenHeight! * 0.01),
                        height: 3,
                        width: (SizeConfig.screenHeight! * 0.4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: darkGreen1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                accDistance,
                                style: const TextStyle(
                                    color: darkGreen2, fontSize: 25),
                              ),
                              const Text(
                                "公里",
                                style:
                                    TextStyle(color: darkGreen2, fontSize: 21),
                              ),
                            ],
                          ),
                          Container(
                            height: (SizeConfig.screenHeight! * 0.1),
                            width: 4.5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: darkGreen1),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                accTrack,
                                style: const TextStyle(
                                    color: darkGreen2, fontSize: 24),
                              ),
                              const Text(
                                "軌跡",
                                style:
                                    TextStyle(color: darkGreen2, fontSize: 21),
                              ),
                            ],
                          ),
                          Container(
                            height: (SizeConfig.screenHeight! * 0.1),
                            width: 4.5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: darkGreen1),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                accActivity,
                                style: const TextStyle(
                                    color: darkGreen2, fontSize: 24),
                              ),
                              const Text(
                                "活動",
                                style:
                                    TextStyle(color: darkGreen2, fontSize: 21),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getMyInfo() async {
    await apiService.getMyInfo(requestModel);
    noteList = await SqliteHelper.queryAll(tableName: "notification");
    if (noteList!.isNotEmpty) {
      showBadge = true;
    } else {
      showBadge = false;
    }
  }
}
