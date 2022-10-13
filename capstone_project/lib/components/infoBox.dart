import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/size_config.dart';
import 'package:capstone_project/ui/setting/updateMyName_page.dart';

class InfoBox extends StatelessWidget {
  final double innerHeight;
  final double innerWidth;
  final bool visible;

  const InfoBox(
      {Key? key,
      required this.innerHeight,
      required this.innerWidth,
      required this.visible})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: innerHeight * 0.2,
          left: innerWidth * 0.1,
          child: SizedBox(
            height: innerHeight, //0.15*0.5
            width: innerWidth,
            child: Column(
              children: [
                Text(
                  UserData.userName,
                  style: const TextStyle(
                    color: darkGreen2,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                    // fontFamily: 'popFonts'
                  ),
                ),
                const VerticalSpacing(percent: 0.01),
                Text(
                  '@' + UserData.userAccount,
                  style: const TextStyle(
                    color: darkGreen2,
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
                  image: AssetImage("assets/images/user.png"),
                ),
              ),
            ),
          ),
        ),
        Positioned(
            top: innerHeight * 0,
            right: innerWidth * 0.015,
            //right: 0,
            child: Visibility(
              visible: visible,
              child: TextButton(
                child: const Text('編輯'),
                style: TextButton.styleFrom(
                  foregroundColor: darkGreen2,
                  backgroundColor: lightGreen2,
                ),
                onPressed: () {
                  print('【按下】更新個人資料 - infoBox');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdateMyInfoPage(),
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }
}
