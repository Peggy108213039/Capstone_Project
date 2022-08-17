//import 'dart:html';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/default_icons.dart';
import 'package:capstone_project/ui/notification_page.dart';
import 'package:capstone_project/ui/setting_page.dart';
import 'package:flutter/material.dart';

class ProfilePageOne extends StatefulWidget {
  const ProfilePageOne({Key? key}) : super(key: key);
  
  @override
  State<ProfilePageOne> createState() => _ProfilePageOneState();
}

class _ProfilePageOneState extends State<ProfilePageOne> {

  @override
  Widget build(BuildContext context) {
    // 去抓使用者手機螢幕的長、寬
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: PrimaryMiddleGreen
          /*decoration: const BoxDecoration(
            color: PrimaryDarkGreen
            // 漸層色
            gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(92, 107, 192, 1),
                  Color.fromARGB(255, 6, 42, 66),
                ],
                // 漸層色的方向
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter),
            
          ),*/
        ),
        Scaffold(
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
                      DefNotificationIcon(enable: true),
                      DefSettingIcon(enable: true,),
                      // IconButton(
                      //   onPressed: (){
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => NotificationPage(),
                      //       ),
                      //     );
                      //   },
                      //   icon: const Icon(
                      //     Icons.notifications_active_outlined,
                      //     color: PrimaryLightYellow,
                      //     size: 30.0,
                      //   ),
                      // ),
                      // IconButton(
                      //   onPressed: (){
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => SettingPage(),
                      //       ),
                      //     );
                      //   },
                      //   icon: const Icon(
                      //     Icons.settings,
                      //     color: PrimaryLightYellow,
                      //     size: 30.0,
                      //   )
                      // )
                    ],
                  ),
                  // 間隔
                  SizedBox(
                    height: (height * 0.025),
                  ),
                  Container(
                    // decoration: const BoxDecoration(color: Colors.amber),
                    height: height * 0.45,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 抓這個 Container 的大小
                        double innerHeight = constraints.maxHeight;
                        double innerWidth = constraints.maxWidth;
                        // Stack
                        return Stack(
                          // 擴展跟 Stack 一樣的大小
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              bottom: innerHeight * 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                // decoration:
                                //     BoxDecoration(color: Colors.green.shade400),
                                height: innerHeight * 0.3,
                                width: innerWidth,
                                child: Column(
                                  children: [
                                    const Text(
                                      '測試帳號',
                                      style: TextStyle(
                                        color: PrimaryLightYellow,
                                        fontSize: 35.0,
                                        // fontFamily: 'popFonts'
                                      ),
                                    ),
                                    SizedBox(
                                      height: (height * 0.025),
                                    ),
                                    const Text(
                                      '@demo1',
                                      style: TextStyle(
                                        color: PrimaryLightYellow,
                                        fontSize: 25.0,
                                        // fontFamily: 'popFonts'
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 放頭貼
                            Positioned(
                              top: innerHeight * 0.05,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  // Container 的大小
                                  width: innerWidth * 0.6,
                                  height: innerWidth * 0.6,
                                  decoration: BoxDecoration(
                                    color: PrimaryLightYellow,
                                    border: Border.all(width: 1),
                                    shape: BoxShape.circle,
                                    image: const DecorationImage(
                                      fit: BoxFit.fill,
                                      image:
                                          AssetImage("assets/images/user.png"),
                                    ),
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
                  // 累積紀錄
                  Container(
                    height: height * 0.2,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.elliptical(
                              width * 0.1, height * 0.5 * 0.1),
                          bottomRight: Radius.elliptical(
                              width * 0.1, height * 0.5 * 0.1),
                          topRight: const Radius.circular(10.0),
                          bottomLeft: const Radius.circular(10.0)),
                      color: PrimaryLightGreen,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          SizedBox(
                            height: (height * 0.01),
                          ),
                          Text(
                            '我的累積紀錄',
                            style: TextStyle(
                              color: PrimaryLightYellow,
                              fontSize: 22,
                              // fontFamily: 'popFonts'
                            ),
                          ),
                          const Divider(
                            thickness: 3,
                          ),
                          Row(
                            // 主軸方向的對齊方式，置中對齊
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  const Text('10 km',
                                      style: TextStyle(
                                          color: PrimaryLightYellow,
                                          // fontFamily: 'popFonts',
                                          fontSize: 25)),
                                  SizedBox(height: (height * 0.01)),
                                  Text('距離',
                                      style: TextStyle(
                                          color: PrimaryLightYellow,
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
                                    color: PrimaryLightYellow
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  const Text('6',
                                    style: TextStyle(
                                      color: PrimaryLightYellow,
                                      // fontFamily: 'popFonts',
                                      fontSize: 25
                                    )
                                  ),
                                  SizedBox(height: (height * 0.01)),
                                  Text('軌跡',
                                      style: TextStyle(
                                          color: PrimaryLightYellow,
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
                                    color: PrimaryLightYellow
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  const Text('3',
                                      style: TextStyle(
                                          color: PrimaryLightYellow,
                                          // fontFamily: 'popFonts',
                                          fontSize: 25)),
                                  SizedBox(height: (height * 0.01)),
                                  Text('活動',
                                      style: TextStyle(
                                          color: PrimaryLightYellow,
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
      ],
    );
  }
}