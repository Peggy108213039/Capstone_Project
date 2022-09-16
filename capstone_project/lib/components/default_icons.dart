import 'package:capstone_project/ui/aboutuser/setting_page.dart';
import 'package:capstone_project/ui/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';
//import 'package:my_capstone_project_ver3/size_config.dart';
// import 'package:capstone_project/ui/aboutuser/setting_page.dart';
// import 'package:capstone_project/ui/notification_page.dart';

class DefBackIcon extends StatelessWidget {
  const DefBackIcon({ 
    Key? key,
    required this.navigatorPage,
  }) : super(key: key);
  final Widget navigatorPage;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => navigatorPage,
          ),
        );
      },
      icon: const Icon(
        Icons.arrow_back,
        color: PrimaryBrown,
        size: 30.0,
      ),
    );
  }
}

class DefCheckIcon extends StatelessWidget {
  const DefCheckIcon({ 
    Key? key,
    required this.navigatorPage,
    required this.onpressed
  }) : super(key: key);
  final Widget navigatorPage;
  final Function() onpressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onpressed,
      icon: const Icon(
        Icons.check,
        color: PrimaryBrown,
        size: 30.0,
      ),
    );
  }
}

class DefNotificationIcon extends StatelessWidget {
  const DefNotificationIcon({ 
    Key? key,
    required this.enable,
  }) : super(key: key);
  final bool enable;

  @override
  Widget build(BuildContext context) {
    if(!enable){
      return IconButton(
        icon: const ImageIcon(
          AssetImage("assets/images/notification.png"),
          //Icons.notifications_active_outlined,
          color: PrimaryLightYellow,
          size: 30.0,
        ),
        onPressed: (){},
      );
    } else{
      return IconButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationPage(),
            ),
          );
        },
        icon: const ImageIcon(
          AssetImage("assets/images/notification.png"),
          color: PrimaryLightYellow,
          size: 30.0,
        ),
      );
    }
  }
}

class DefSettingIcon extends StatelessWidget {
  const DefSettingIcon({ // button onPressed pre-announce param
    Key? key,
    required this.enable,
  }) : super(key: key);
  final bool enable;

  @override
  Widget build(BuildContext context) {
    if(!enable){
      return IconButton(
        icon: const ImageIcon(
          AssetImage("assets/images/setting.png"),
          //Icons.settings,
          color: PrimaryLightYellow,
          size: 30.0,
        ),
        onPressed: (){},
      );
    } else{
      return IconButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingPage(),
            ),
          );
        },
        icon: const ImageIcon(
          AssetImage("assets/images/setting.png"),
          color: PrimaryLightYellow,
          size: 30.0,
        )
      );
    }
    
  }
}