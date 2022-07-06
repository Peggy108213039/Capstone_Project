import 'package:capstone_project/bottom_bar.dart';
import 'package:flutter/material.dart';
// import 'package:my_mountain_app/profile_page_one.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyBottomBar(),
    );
  }
}
