import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/default_buttons.dart';
import 'package:capstone_project/components/default_icons.dart';
import 'package:capstone_project/ui/notification_page.dart';
import 'package:capstone_project/ui/login_page.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: PrimaryMiddleGreen,
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
                      DefSettingIcon(enable: false,),
                    ],
                  ),
                  Container( 
                    decoration: /*const*/ BoxDecoration(
                      //color: Color.fromARGB(255, 196, 233, 243),
                      border: Border.all(color: PrimaryLightYellow, width: 3)
                    ),
                    height: height * 0.15,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double innerHeight = constraints.maxHeight;
                        double innerWidth = constraints.maxWidth;
                        // Stack
                        return Stack(
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
                                  // Container ???è¸???­å??è³??????å°???­å???
                                  width: innerWidth * 0.25,
                                  height: innerWidth * 0.25,
                                  decoration: BoxDecoration(
                                    color: PrimaryLightYellow,
                                    border: Border.all(
                                        width: 1,
                                        color: PrimaryLightYellow),
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
                    height: (height * 0.02),
                  ),
                  Container(
                    height: height*0.6,
                    width: width,
                    decoration: BoxDecoration(
                      //border: Border.all(color: Color.fromARGB(255, 255, 255, 255), width: 3),
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: (height * 0.01),
                          ),
                          const Text(
                            '??ºæ?¬è¨­å®?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: PrimaryLightYellow,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(
                            height: (height * 0.02),
                          ),
                          Container(
                            decoration:BoxDecoration(
                              border: Border.all(color: PrimaryLightYellow, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            height: height*0.08, //0.15*0.5
                            width: width,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(7),
                            child: Text(
                              'ä¿¡ç®±ï¼?demo@gmail.com',
                              style: TextStyle(
                                color: PrimaryLightYellow,
                                fontSize: 18
                              ),
                            ),
                          ),
                          Container(
                            decoration:BoxDecoration(
                              border: Border.all(color: PrimaryLightYellow, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            height: height*0.08, //0.15*0.5
                            width: width,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(7),
                            child: const Text(
                              '??»è©±???ç¢¼ï??0900-000000',
                              style: TextStyle(
                                color: PrimaryLightYellow,
                                fontSize: 18
                              ),
                            ),
                          ),
                          Container(
                            decoration:BoxDecoration(
                              border: Border.all(color: PrimaryLightYellow, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            height: height*0.08, //0.15*0.5
                            width: width,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(7),
                            child: const Text(
                              '???è¨­å??ç¢?',
                              style: TextStyle(
                                color: PrimaryLightYellow,
                                fontSize: 18
                              ),
                            ),
                          ),
                          SizedBox(
                            height: (height * 0.02),
                          ),
                          const Text(
                            '??¶ä????????',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: PrimaryLightYellow,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(
                            height: (height * 0.02),
                          ),
                          Container(
                            decoration:BoxDecoration(
                              border: Border.all(color: PrimaryLightYellow, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            height: height*0.08, //0.15*0.5
                            width: width,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(7),
                            child: const Text(
                              '?????©å·¥???',
                              style: TextStyle(
                                color: PrimaryLightYellow,
                                fontSize: 18
                              ),
                            ),
                          ),
                          Container(
                            decoration:BoxDecoration(
                              border: Border.all(color: PrimaryLightYellow, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            height: height*0.08, //0.15*0.5
                            width: width,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(7),
                            child: const Text(
                              '?????¼æ?????',
                              style: TextStyle(
                                color: PrimaryLightYellow,
                                fontSize: 18
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DefaultSmallButton(
                    text: "??»å??",
                    onpressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
