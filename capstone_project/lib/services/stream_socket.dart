import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/services/notification_service.dart';
import 'package:capstone_project/services/polyline_coordinates_model.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';

class StreamSocket {
  static final StreamController<Object> _socketResponse =
      StreamController<Object>();
  static Stream<Object> get getResponse => _socketResponse.stream;

  static final IO.Socket _socket = IO.io(
      'http://163.22.17.247:3000',
      IO.OptionBuilder()
          .setAuth({'account': UserData.userAccount}).setTransports(
              ['websocket']).build());

  static connectAndListen() async {
    print('CONNECT AND LISTEN');
    try {
      _socket.connect();
      _socket.onConnect((_) {
        print('============\nSOCKET 連線 成功\n============');

      });
      // 監聽頻道
      _socket.on('account', (accountData) async {
        // print('SOCKET ACCOUNT 頻道訊息 : $accountData  ${accountData.runtimeType}');
        if (accountData.runtimeType != String &&
            accountData['ctlmsg'] != null) {
          final String ctlMsg = accountData['ctlmsg'];
          if (ctlMsg == "activity insert") {
            List activityMsg =
                accountData['activity_msg'].toString().split(' ');
            await NotificationService().showNotification(
                1, 'main_channel', '新增 ${activityMsg[1]} 活動', '可以到活動頁面查看');
            // 寫進 sqlite
            var activityName = accountData['activity_msg'];
            var insertData = {
              "ctlmsg": "activity update",
              "account_msg": "",
              "friend_msg": "",
              "activity_msg": activityName,
              "info": "你已被加入 $activityName 活動"
            };
            await SqliteHelper.insert(
                tableName: 'notification', insertData: insertData);
          }
          if (ctlMsg == "activity update") {
            // 寫進 sqlite
            var activityName = accountData['activity_msg'];
            var insertData = {
              "ctlmsg": "activity update",
              "account_msg": "",
              "friend_msg": "",
              "activity_msg": activityName,
              "info": "你已被加入 $activityName 活動"
            };
            await SqliteHelper.insert(
                tableName: 'notification', insertData: insertData);
          }
          if (ctlMsg == "activity start") {
            List activityMsg =
                accountData['activity_msg'].toString().split(' ');
            await NotificationService().showNotification(
                1, 'main_channel', '${activityMsg[1]} 活動開始', '可以去記錄活動了 !');
            // 寫進 sqlite
            var activityName = accountData['activity_msg'];
            var insertData = {
              "ctlmsg": "activity start",
              "account_msg": "",
              "friend_msg": "",
              "activity_msg": activityName,
              "info": "$activityName 活動開始了"
            };
            await SqliteHelper.insert(
                tableName: 'notification', insertData: insertData);
          }
          if (ctlMsg == "activity finish") {
            List activityMsg =
                accountData['activity_msg'].toString().split(' ');
            await NotificationService().showNotification(
                1, 'main_channel', '${activityMsg[1]} 活動已結束', '');
            // 寫進 sqlite
            var activityName = accountData['activity_msg'];
            var insertData = {
              "ctlmsg": "activity start",
              "account_msg": "",
              "friend_msg": "",
              "activity_msg": activityName,
              "info": "$activityName 活動結束了"
            };
            await SqliteHelper.insert(
                tableName: 'notification', insertData: insertData);
          }
          if (ctlMsg == 'friend request') {
            var who = accountData['account_msg'];
            await NotificationService()
                .showNotification(2, 'main_channel', '$who 向你發送好友邀請', '');
            var insertData = {
              "ctlmsg": "friend request",
              "account_msg": who,
              "friend_msg": "",
              "activity_msg": "",
              "info": "$who 向你發送好友邀請"
            };
            print("有人發好友邀請給我");
            await SqliteHelper.insert(
                tableName: 'notification', insertData: insertData);
          }
          if (ctlMsg == 'friend response') {
            var who = accountData['account_msg'].toString();
            await NotificationService()
                .showNotification(2, 'main_channel', '$who 接受了你的好友邀請', '');
            var insertData = {
              "ctlmsg": "friend response",
              "account_msg": who,
              "friend_msg": "",
              "activity_msg": "",
              "info": "$who 接受了你的好友邀請"
            };
            await SqliteHelper.insert(
                tableName: 'notification', insertData: insertData);
          }
        }
        _socketResponse.add(accountData);
      });
      _socket.on('activity', (activityData) async {
        // print('SOCKET 活動頻道訊息 : $activityData');
        if (activityData.runtimeType != String) {
          final String ctlMsg = activityData['ctlmsg'];
          if (ctlMsg == "activity warning") {
            final String wanringMsg = activityData['wanring_msg'];
            // 某人距離過遠
            if (wanringMsg == "too far") {
              // 在 client 顯示 UI 某人距離過遠
              await NotificationService().showNotification(
                  3,
                  'main_channel',
                  '${activityData['account_msg_1']} 和 ${activityData['account_msg_2']} 距離過遠',
                  '相差的距離 : ${double.parse(activityData['long_distance'].toString()).toStringAsFixed(2)} 公尺');
            }
            // 某人停留時間過久
            if (wanringMsg == "too long") {
              activityMemberStopTooLongText.value +=
                  '${activityData['account_msg']} 停留時間過久，目前位置:\n經度: ${activityData['location_msg']['longitude']}\n緯度: ${activityData['location_msg']['latitude']}\n高度: ${activityData['location_msg']['elevation']}\n\n';
              showActivityMemberStopTooLongText.value = true;
              await NotificationService().showNotification(
                  4,
                  'main_channel',
                  '${activityData['account_msg']} 停留時間過久',
                  '目前位置 經度: ${activityData['location_msg']['longitude']} 緯度: ${activityData['location_msg']['latitude']} 高度: ${activityData['location_msg']['elevation']}');
            }
          }
          if (ctlMsg == "broadcast location") {
            getMemberLocation(socketData: activityData);
          }
        }
        _socketResponse.add(activityData);
      });
    } catch (error) {
      print('ERROR :\n$error');
    }
  }

  static loginSend() async {
    try {
      if(!_socket.active){
        _socket.onReconnect((data) => _socket.connect());
        print("socket 重新連線");
      }
      _socket.emit('ctlmsg',
          {'ctlmsg': 'join account room', 'account_msg': UserData.userAccount});
      _socket.emit('ctlmsg', {'ctlmsg': 'check', 'account_msg': UserData.userAccount});
    } catch (error) {
      print('ERROR: $error');
    }
  }

  // static checkInRoom() async {
  //   try {
  //     _socket.onConnect((data) => null);
  //     _socket.emit('ctlmsg', {'ctlmsg': 'check', 'account_msg': UserData.userAccount});
  //   } catch (error) {
  //     print("ERROR: $error");
  //   }
  // }

  // emit invitation msg to server
  Future<void> joinActivityRoom(String activityName) async {
    try {
      _socket.emit('ctlmsg', {
        'ctlmsg': 'join activity room',
        'activity_msg': activityName,
        'account_msg': UserData.userAccount
      });
      print('JOIN ACCOUNT ROOM');
    } catch (error) {
      print('SOCKET ERROR: $error');
    }
  }

  // emit invitation msg to server
  Future<void> friendRequest(String friendAccount) async {
    try {
      print("socket 連線狀態: ${_socket.connected}");
      if(!_socket.active){
        _socket.onReconnect((data) => _socket.connect());
        print("socket 重新連線");
      }

      _socket.emit('ctlmsg', {
        'ctlmsg': 'friend request',
        'account_msg': UserData.userAccount, // 發邀請者的 account
        'friend_msg': friendAccount // 被邀請者 account
      });
      print('FRIEND REQUEST');
    } catch (error) {
      print('ERROR: $error');
    }
  }

  // emit invitation msg to server
  Future<void> friendResponse(String friendAccount) async {
    try {
      _socket.emit('ctlmsg', {
        'ctlmsg': 'friend response',
        'friend_msg': friendAccount, // 欲邀請好友的 account
        'account_msg': UserData.userAccount // 發邀請者的 account
      });
      print('FRIEND RESPONSE');
    } catch (error) {
      print('ERROR: $error');
    }
  }

  Future<void> reportActivityInvitation() async {}

  Future<void> reportAlertNotification() async {}

  static Future<void> uploadUserLocation(
      {required String activityMsg,
      required double warningDistance,
      required UserLocation location}) async {
    try {
      _socket.emit('ctlmsg', {
        "ctlmsg": "broadcast location",
        "account_msg": UserData.userAccount,
        "activity_msg": activityMsg,
        "distance_msg": warningDistance,
        "location_msg": {
          "latitude": location.latitude.toString(),
          "longitude": location.longitude.toString(),
          "elevation": location.altitude.toString()
        }
      });
    } catch (error) {
      print('SOCKET ERROR: $error');
    }
  }

  static Future<void> warningTimeTooLong(
      {required String activityMsg, required UserLocation location}) async {
    try {
      _socket.emit('ctlmsg', {
        "ctlmsg": "activity warning",
        "wanring_msg": "too long",
        "activity_msg": activityMsg,
        "account_msg": UserData.userName.toString(),
        "time_msg": DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        "location_msg": {
          "latitude": location.latitude.toString(),
          "longitude": location.longitude.toString(),
          "elevation": location.altitude.toString()
        }
      });
    } catch (error) {
      print('SOCKET ERROR: $error');
    }
  }

  static dispose() async {
    print('結束 socket 連線');
    _socketResponse.close();
    _socket.disconnect();
    _socket.dispose();
    print("SOCKET IO CLIENT CLOSE CONNECTION");
  }

  static void getMemberLocation({required Object? socketData}) {
    // List<Polyline> polylineList = [];
    final tmpSocketData = jsonDecode(jsonEncode(socketData!));
    // print('socketData $tmpSocketData  type ${tmpSocketData.runtimeType}');
    // List<Polyline>
    // if (tmpSocketData.runtimeType != String &&
    //     tmpSocketData['ctlmsg'] != null) {
    // final String ctlMsg = tmpSocketData['ctlmsg'];
    // FIXME client 收到同行者的軌跡
    // if (ctlMsg == "broadcast location") {
    // 檢查 memberName 有沒有在 activityFrindsIDList 裡
    // 沒有就新增一個 PolylineCoordinates
    String memberName = tmpSocketData['account_msg'].toString();
    // int randomColor = Random().nextInt(Colors.primaries.length);
    List randomColor = [
      Random().nextInt(255),
      Random().nextInt(255),
      Random().nextInt(255)
    ];
    if (!activityFrindsIDList.contains(memberName)) {
      activityFrindsIDList.add(memberName);
      // PolylineCoordinates tempPolyline = PolylineCoordinates();
      activityPolyLineList.add({
        "account": memberName,
        // "polyline": tempPolyline,
        "color": randomColor
      });
      activirtMemberMarkers.add(Marker(
          width: 15,
          height: 15,
          point: LatLng(double.parse(tmpSocketData['location_msg']['latitude']),
              double.parse(tmpSocketData['location_msg']['longitude'])),
          builder: (context) => Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(
                        activityPolyLineList.last['color'][0],
                        activityPolyLineList.last['color'][1],
                        activityPolyLineList.last['color'][2],
                        1),
                    shape: BoxShape.circle,
                    border: Border.all(width: 3, color: Colors.white)),
              )));
    }
    // 將 socket 收到的位置記錄起來
    for (int i = 0; i < activityPolyLineList.length; i++) {
      if (tmpSocketData['account_msg'] == activityPolyLineList[i]['account']) {
        // activityPolyLineList[i]['polyline'].recordCoordinates(UserLocation(
        //     latitude:
        //         double.parse(tmpSocketData['location_msg']['latitude']),
        //     longitude:
        //         double.parse(tmpSocketData['location_msg']['longitude']),
        //     altitude:
        //         double.parse(tmpSocketData['location_msg']['elevation']),
        //     currentTime: UserLocation.getCurrentTime()));
        activirtMemberMarkers[i] = Marker(
            width: 15,
            height: 15,
            point: LatLng(
                double.parse(tmpSocketData['location_msg']['latitude']),
                double.parse(tmpSocketData['location_msg']['longitude'])),
            builder: (context) => Container(
                  decoration: BoxDecoration(
                      // activityPolyLineList[i]['color']
                      color: Color.fromRGBO(
                          activityPolyLineList[i]['color'][0],
                          activityPolyLineList[i]['color'][1],
                          activityPolyLineList[i]['color'][2],
                          1),
                      shape: BoxShape.circle,
                      border: Border.all(width: 3, color: Colors.white)),
                ));
        memberMarkersUpdate = true;
      }
    }
    // 回傳 List<polyline>
    // if (activityPolyLineList.isNotEmpty) {
    //   for (int i = 0; i < activityPolyLineList.length; i++) {
    //     polylineList.add(Polyline(
    //       points: activityPolyLineList[i]['polyline'].list,
    //       color: Colors.primaries[activityPolyLineList[i]['color']],
    //       strokeWidth: 4,
    //     ));
    //   }
    // }
    // print('activityPolyLineList $activityPolyLineList');
    // }
    // }
  }
}
