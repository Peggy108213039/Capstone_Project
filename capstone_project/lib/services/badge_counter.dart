import 'dart:async';
import 'dart:convert';
import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/services/notification_service.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class BadgeCounter {
  // 存放使用者資料
  static late int badgeCounter = 0;

  BadgeCounter(int counter){
    badgeCounter += counter;
  }

  void addBadge(counter) {
    badgeCounter++;
  }

}