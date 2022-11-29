import 'dart:async';
import 'dart:convert';
import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/services/notification_service.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
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
      print("CONNECTING");
      _socket.onConnect((_) {
        print('CONNECTION ESTABLISHED');
      });
      print('============\nSOCKET 連線\n============');
      // 監聽頻道
      _socket.on('account', (accountData) async {
        print(
            'SOCKET ACCOUNT CHANNEL MSG : $accountData  ${accountData.runtimeType}');
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
          if (ctlMsg == "activity warning") {
            final String wanringMsg = accountData['wanring_msg'];
            // FIXME  某人距離過遠
            if (wanringMsg == "too far") {
              // FIXME 在 client 顯示 UI 某人距離過遠
              await NotificationService().showNotification(
                  1,
                  'main_channel',
                  '同行者距離過遠',
                  '${accountData['account_msg_1']} 和 ${accountData['account_msg_2']} 距離過遠\n兩人相差的距離 : ${accountData['long_distance']}');
            }
            // FIXME  某人停留時間過久
            if (wanringMsg == "too long") {
              // print('停留時間過久 accountData $accountData');
              await NotificationService().showNotification(
                  1,
                  'main_channel',
                  '同行者停留時間過久',
                  '${accountData['account_msg']} 停留時間過久\n${accountData['location_msg']}');
            }
          }
        }
        _socketResponse.add(accountData);
      });
      _socket.on('activity', (activityData) {
        if (activityData.runtimeType != String) {}
        _socketResponse.add(activityData);
        print('SOCKET ACTIVITY CHANNEL MSG : $activityData');
        // 直接在這裡寫在 sqlite
      });
    } catch (error) {
      print('ERROR :\n$error');
    }
  }

  static loginSend() async {
    try {
      _socket.emit('ctlmsg',
          {'ctlmsg': 'join account room', 'account_msg': UserData.userAccount});
    } catch (error) {
      print('ERROR: $error');
    }
  }

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
}
