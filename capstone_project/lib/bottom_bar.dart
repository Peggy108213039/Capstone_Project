import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/ui/activity/activity_page.dart';
import 'package:capstone_project/ui/friend/friend_page copy 2.dart';
import 'package:capstone_project/ui/map/map_page.dart';
import 'package:capstone_project/ui/route_page.dart';
import 'package:capstone_project/ui/profile_page.dart';

class MyBottomBar extends StatefulWidget {
  const MyBottomBar({Key? key}) : super(key: key);

  @override
  State<MyBottomBar> createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar>{
  // when button clicked
  int _selectedIndex = 2;

  final List<Widget> pages = [
    const MapPage(),
    const RoutePage(),
    const ProfilePage(),
    const ActivityPage(),
    const FriendPage(),
  ];

  void _onItemTapped(int idx) {
    setState(() {
      _selectedIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: PrimaryDarkGreen,
        currentIndex: _selectedIndex, 
        selectedItemColor: PrimaryLightYellow, 
        unselectedItemColor: PrimaryLightGreen,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/map.png"),
              ),
              label: '地圖'),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/route.png"),
                //Icons.route_outlined,
              ),
              label: '路徑'),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/home.png")
                //Icons.home,
              ),
              label: '首頁'),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/activity.png")
                //Icons.hiking,
              ),
              label: '活動'),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("assets/images/friend.png")
                //Icons.people_outline_outlined,
              ),
              label: '好友'),
        ],
      ),
    );
  }
}