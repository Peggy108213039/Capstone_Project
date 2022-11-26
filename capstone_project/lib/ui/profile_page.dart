import 'package:capstone_project/models/userInfo/getInfo.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:flutter/material.dart';
// basic setting
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/default_icons.dart';
import 'package:capstone_project/services/http_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageOneState();
}

class _ProfilePageOneState extends State<ProfilePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  APIService apiService = APIService();
  late getInfoRequestModel requestModel = getInfoRequestModel(uID: UserData.uid.toString());

  String userName = ''; // catch & print userinfo table
  String userAccount = '';
  String accDistance = '';
  String accTrack = '';
  String accActivity = '';

  @override
  void initState() {
    super.initState();
    getMyInfo();
    userName = UserData.userName.toString(); // catch & print userinfo table
    userAccount = UserData.userAccount;
    accDistance = UserData.totalDistance.toString();
    accTrack = UserData.totalTrack.toString();
    accActivity = UserData.totalActivity.toString();
  }

  @override
  Widget build(BuildContext context) {
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
                  children: <Widget>[
                    DefNotificationIcon(enable: true,),
                    const DefSettingIcon(enable: true,),
                  ],
                ),
                SizedBox(
                  height: (height * 0.025),
                ),
                SizedBox(
                  // decoration: const BoxDecoration(color: Colors.amber),
                  height: height * 0.45,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double innerHeight = constraints.maxHeight;
                      double innerWidth = constraints.maxWidth;
                      // Stack
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                            bottom: innerHeight * 0,
                            left: 0,
                            right: 0,
                            child: SizedBox(
                              // decoration:
                              //     BoxDecoration(color: Colors.green.shade400),
                              height: innerHeight * 0.3,
                              width: innerWidth,
                              child: Column(
                                children: [
                                  Text(
                                    // 使用者名稱
                                    userName,
                                    style: const TextStyle(
                                      color: darkGreen2,
                                      fontSize: 35.0,
                                      // fontFamily: 'popFonts'
                                    ),
                                  ),
                                  SizedBox(
                                    height: (height * 0.025),
                                  ),
                                  Text(
                                    // 使用者帳號
                                    "@" + userAccount,
                                    style: const TextStyle(
                                      color: darkGreen2,
                                      fontSize: 25.0,
                                      // fontFamily: 'popFonts'
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: innerHeight * 0.05,
                            left: 0,
                            right: 0,
                            child: Center(
                              // 大頭貼
                              child: Container(
                                width: innerWidth * 0.6,
                                height: innerWidth * 0.6,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: transparentColor,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Image(
                                  image: defaultUserImage,
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: (height * 0.025),
                ),
                Container(
                  height: height * 0.2,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.elliptical(width * 0.1, height * 0.5 * 0.1),
                        bottomRight:
                            Radius.elliptical(width * 0.1, height * 0.5 * 0.1),
                        topRight: const Radius.circular(10.0),
                        bottomLeft: const Radius.circular(10.0)),
                    color: semiTransparentColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        SizedBox(
                          height: (height * 0.01),
                        ),
                        const Text(
                          '累積紀錄',
                          style: TextStyle(
                            color: darkGreen2,
                            fontSize: 22,
                            // fontFamily: 'popFonts'
                          ),
                        ),
                        const Divider(
                          thickness: 3,
                          color: darkGreen1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(accDistance,
                                    style: const TextStyle(
                                        color: darkGreen2,
                                        // fontFamily: 'popFonts',
                                        fontSize: 25)),
                                SizedBox(height: (height * 0.01)),
                                const Text('距離',
                                    style: TextStyle(
                                        color: darkGreen2,
                                        // fontFamily: 'popFonts',
                                        fontSize: 21))
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 8),
                              child: Container(
                                height: (height * 0.1),
                                width: 4.5,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: darkGreen1),
                              ),
                            ),
                            Column(
                              children: [
                                Text(accTrack,
                                    style: const TextStyle(
                                        color: darkGreen2,
                                        // fontFamily: 'popFonts',
                                        fontSize: 25)),
                                SizedBox(height: (height * 0.01)),
                                const Text('路徑',
                                    style: TextStyle(
                                        color: darkGreen2,
                                        // fontFamily: 'popFonts',
                                        fontSize: 21))
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 8),
                              child: Container(
                                height: (height * 0.1),
                                width: 4.5,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: darkGreen1),
                              ),
                            ),
                            Column(
                              children: [
                                Text(accActivity,
                                    style: const TextStyle(
                                        color: darkGreen2,
                                        // fontFamily: 'popFonts',
                                        fontSize: 25)),
                                SizedBox(height: (height * 0.01)),
                                const Text('活動',
                                    style: TextStyle(
                                        color: darkGreen2,
                                        // fontFamily: 'popFonts',
                                        fontSize: 21))
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
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
  } 
}
