import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/size_config.dart';
import 'package:capstone_project/ui/notification_page.dart';
import 'package:capstone_project/ui/setting_page.dart';

class DefNotificationIcon extends StatelessWidget {
  const DefNotificationIcon({ // button onPressed 的方法透過建構傳入
    Key? key,
    required this.enable,
  }) : super(key: key);
  final bool enable;

  @override
  Widget build(BuildContext context) {
    if(!enable){
      return IconButton(
        icon: const Icon(
          Icons.notifications_active_outlined,
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
              builder: (context) => NotificationPage(),
            ),
          );
        },
        icon: const Icon(
          Icons.notifications_active_outlined,
          color: PrimaryLightYellow,
          size: 30.0,
        ),
      );
    }
  }
}

class DefSettingIcon extends StatelessWidget {
  const DefSettingIcon({ // button onPressed 的方法透過建構傳入
    Key? key,
    required this.enable,
  }) : super(key: key);
  final bool enable;

  @override
  Widget build(BuildContext context) {
    if(!enable){
      return IconButton(
        icon: const Icon(
          Icons.settings,
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
              builder: (context) => SettingPage(),
            ),
          );
        },
        icon: const Icon(
          Icons.settings,
          color: PrimaryLightYellow,
          size: 30.0,
        )
      );
    }
    
  }
}