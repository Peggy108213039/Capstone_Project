// import 'dart:html'
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/default_icons.dart';
import 'package:capstone_project/services/api_service.dart';
import 'package:capstone_project/ui/setting_page.dart';
import 'package:flutter/material.dart';

import '../components/loadingAnimation.dart';
import '../models/friend/checkFriend_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();
  bool hidePassword = true;
  late CheckFriendRequestModel requestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    requestModel = new CheckFriendRequestModel(
      uID1: 9, // FIXME 0815: catch userID
      // uID2: int.parse('')
      uID2: 10
    );
  }

  @override
  Widget build(BuildContext context){
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3, 
    );
  }

  @override
  Widget _uiSetup(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: PrimaryMiddleGreen
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Padding( 
              padding: EdgeInsets.symmetric(
                  horizontal: (width * 0.035),
                  vertical: (height * 0.05)
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // DefNotificationIcon(),
                      IconButton(
                        onPressed: (){},
                        icon: const Icon(
                          Icons.notifications_active_outlined,
                          color: PrimaryLightYellow,
                          size: 30.0,
                        ),
                      ),
                      DefSettingIcon(enable: true),
                    ],
                  ),
                  Container(
                    decoration: /*const*/ BoxDecoration(
                      //color: Color.fromARGB(255, 196, 233, 243),
                      border: Border.all(color: PrimaryLightYellow, width: 3)
                    ),
                    height: height * 0.15, // container
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Container
                        double innerHeight = constraints.maxHeight;
                        double innerWidth = constraints.maxWidth;
                        // Stack
                        return Stack(
                          // Stack
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              top: innerHeight * 0.2,
                              left: innerWidth * 0.1,
                              //right: 0,
                              child: Container(
                                // decoration:
                                //     BoxDecoration(color: Colors.green.shade400),
                                height: innerHeight, //0.15*0.5
                                width: innerWidth ,
                                child: Column(
                                  children: [
                                    const Text(
                                      'æ¸¬è©¦å¸³è??',
                                      style: TextStyle(
                                        color: PrimaryLightYellow,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: 'popFonts'
                                      ),
                                    ),
                                    SizedBox(
                                      height: (height * 0.01),
                                    ),
                                    const Text(
                                      '@demo1',
                                      style: TextStyle(
                                        color: PrimaryLightYellow,
                                        fontSize: 20.0,
                                        // fontFamily: 'popFonts'
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: innerHeight * 0.125,
                              left: innerWidth * 0.05,
                              //right: 0,
                              child: Center(
                                child: Container(
                                  width: innerWidth * 0.25,
                                  height: innerWidth * 0.25,
                                  decoration: BoxDecoration(
                                    color: PrimaryLightYellow,
                                    border: Border.all(width: 1, color: PrimaryLightYellow),
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
                    height: (height * 0),
                  ),
                  // notification list
                  Container(
                    /*height: height * 0.1,
                    width: width,
                    padding: EdgeInsets.only(left: 20),
                    alignment:Alignment.centerLeft,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),*/

                    child: ListView(
                      children: <Widget> [
                        Card(
                          child: ListTile(
                            tileColor: PrimaryMiddleYellow,
                            title:Text("??¨å·²è¢«å????¥æ?¥æ??æ½­æ´»???ä¸?") ,
                          ),
                        ),
                        Card(
                          child: ListTile(
                            tileColor: PrimaryMiddleYellow,
                            title: Text("@test1 ?????¨ç?¼å?ºä??å¥½å?????è«?"),
                            onTap: (){
                              showAlert(context);
                            }
                          ),
                        ),
                      ],
                      shrinkWrap: true,
                    )
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> showAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: PrimaryLightYellow,
          title: Text('ç¢ºè??å¥½å??'),
          content: const Text('ç¢ºå????? @Test1 ?????ºå¥½???ï¼?'),
          actions: <Widget>[
            FlatButton(
              child: Text('??¥å??'),
              onPressed: () {
                setState(() { // show waiting signal while click accept btn
                  isApiCallProcess = true;
                });
                APIService apiService = new APIService();
                apiService.checkFriend(requestModel).then((value) {
                  if (value){
                    setState(() {
                      isApiCallProcess = false;
                    });
                    Navigator.of(context).pop(NotificationPage());
                    print('You Accepted a Friend');
                  } else {
                    print("Accept Friend Invitation Failed");
                  }
                },);
              },
            ),
            FlatButton(
              child: const Text('???çµ?'), 
              onPressed: () {
                print('You Denied Nobody');
                Navigator.of(context).pop(NotificationPage());
              },
            )
          ],
        );
      },
    );
  }
}