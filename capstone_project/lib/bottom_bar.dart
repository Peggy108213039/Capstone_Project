import 'package:capstone_project/ui/map/locationProvider.dart';
import 'package:capstone_project/ui/track/track_page.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/ui/activity/activity_page.dart';
import 'package:capstone_project/ui/friend/friend_page copy 2.dart';
import 'package:capstone_project/ui/profile_page.dart';

class MyBottomBar extends StatefulWidget {
  final int i;
  final bool firstTime;
  const MyBottomBar({Key? key, required this.i, required this.firstTime}) : super(key: key);

  @override
  State<MyBottomBar> createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar>{
  bool _firstTime = true;
  // when button clicked
  int _selectedIndex = 2;

  final List<Widget> pages = [
    // Map
    const LocationProvider(
      mapService: 'FlutterMapPage',
    ), // 0
    const TrackPage(), // 1
    const ProfilePage(),
    const ActivityPage(), // 3
    const FriendPage(),
  ];

  void _onItemTapped(int idx) {
    setState(() {
      _selectedIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.firstTime && _firstTime){
      // FIXME 一開啟 APP 就將 sqlite 的資料更新成 server 的資料
      _firstTime = false;
    }
    if (!widget.firstTime && _firstTime) {
      _selectedIndex = widget.i;
      _firstTime = false;
    }
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
              label: '軌跡'),
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