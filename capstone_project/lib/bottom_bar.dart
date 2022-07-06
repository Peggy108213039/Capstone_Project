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
  // 指目前是哪一個 btn 被按到
  int _selectedIndex = 2;
  // 這是要在 body 中呈現的畫面
  final List<Widget> pages = [
    const MapPage(),
    const RoutePage(),
    const ProfilePageOne(),
    const ActivityPage(),
    const FriendsPage()
  ];
  // 按 btn 的 function
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
        backgroundColor: Colors.indigo.shade400,
        currentIndex: _selectedIndex, // 指目前被點到的 btn index
        selectedItemColor: Colors.white, // 目前被點到的 btn 要呈現的顏色
        unselectedItemColor: Colors.blueGrey.shade200,
        onTap: _onItemTapped, // 被點到的 btn 要執行的 function
        // 四個 btn (item)
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.map,
              ),
              // label：btn icon 要呈現的小字
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
              label: '活動列表'),
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
