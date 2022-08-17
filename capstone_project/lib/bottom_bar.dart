import 'package:capstone_project/constants.dart';
import 'package:capstone_project/ui/activity_page.dart';
import 'package:capstone_project/ui/friend_page.dart';
import 'package:capstone_project/ui/map_page.dart';
import 'package:capstone_project/ui/profile_page_one.dart';
import 'package:capstone_project/ui/route_page.dart';
import 'package:flutter/material.dart';

class MyBottomBar extends StatefulWidget {
  const MyBottomBar({Key? key}) : super(key: key);

  @override
  State<MyBottomBar> createState() => _MyBottomBarState();
}

class _MyBottomBarState extends State<MyBottomBar> {
  int _selectedIndex = 2;
  final List<Widget> pages = [
    const MapPage(),
    const RoutePage(),
    const ProfilePageOne(),
    const ActivityPage(),
    const FriendPage()
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
              icon: Icon(
                Icons.map,
              ),
              label: '地圖'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.route_outlined,
              ),
              label: '軌跡'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: '首頁'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.hiking,
              ),
              label: '活動'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.people_outline_outlined,
              ),
              label: '好友'),
        ],
      ),
    );
  }
}
