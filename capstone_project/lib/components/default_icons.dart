import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

import 'package:capstone_project/constants.dart';
import 'package:capstone_project/services/badge_counter.dart';
import 'package:capstone_project/ui/setting/setting_page.dart';
import 'package:capstone_project/ui/notification/notification_page.dart';

class DefBackIcon extends StatelessWidget {
  const DefBackIcon({
    Key? key,
    required this.navigatorPage,
  }) : super(key: key);
  final Widget navigatorPage;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => navigatorPage,
          ),
        );
      },
      icon: const ImageIcon(backIcon2),
    );
  }
}

class DefCheckIcon extends StatelessWidget {
  const DefCheckIcon(
      {Key? key, required this.navigatorPage, required this.onpressed})
      : super(key: key);
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
    required this.show
  }) : super(key: key);
  final bool enable;
  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!enable) {
      return IconButton(
        icon: const ImageIcon(
          AssetImage("assets/images/other_icons/notification.png"),
          color: darkGreen2,
          size: 30.0,
        ),
        onPressed: () {},
      );
    } else {
      return Badge(
        showBadge: show,
        position: BadgePosition.topEnd(top: 1, end: 3),
        badgeColor: Colors.red,
        badgeContent: const Text("9", style: TextStyle(color: unselectedColor),),
        child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationPage(),
            ),
          );
        },
        icon: const ImageIcon(
          AssetImage("assets/images/other_icons/notification.png"),
          color: darkGreen2,
          size: 30.0,
        ),
      ));
    }
  }
}

class DefSettingIcon extends StatelessWidget {
  const DefSettingIcon({
    // button onPressed pre-announce param
    Key? key,
    required this.enable,
  }) : super(key: key);
  final bool enable;

  @override
  Widget build(BuildContext context) {
    if (!enable) {
      return IconButton(
        icon: const ImageIcon(
          AssetImage("assets/images/other_icons/setting.png"),
          //Icons.settings,
          color: darkGreen2,
          size: 30.0,
        ),
        onPressed: () {},
      );
    } else {
      return IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingPage(),
              ),
            );
          },
          icon: const ImageIcon(
            AssetImage("assets/images/other_icons/setting.png"),
            color: darkGreen2,
            size: 30.0,
          ));
    }
  }
}
