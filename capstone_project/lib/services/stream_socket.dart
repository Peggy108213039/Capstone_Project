import 'dart:async';
import 'dart:convert';
import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/services/notification_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
      // 監聽頻道
      _socket.on('account', (accountData) async {
        if (accountData.runtimeType != String) {
          if (accountData['ctlmsg'] == "activity update") {
            List activityMsg =
                accountData['activity_msg'].toString().split(' ');
            NotificationService().showNotification(
                1, 'main_channel', '新增 ${activityMsg[1]} 活動', '可以到活動頁面查看');
            // FIXME : 更新活動資料跟 server 一樣
            var userID = {'uID': UserData.uid.toString()};
            await APIService.selectAccountActivity(content: userID);
          }
          if (accountData['ctlmsg'] == "activity start") {
            List activityMsg =
                accountData['activity_msg'].toString().split(' ');
            NotificationService().showNotification(
                1, 'main_channel', '${activityMsg[1]} 活動開始', '可以去記錄活動了 !');
            // FIXME : 更新活動資料跟 server 一樣
            var userID = {'uID': UserData.uid.toString()};
            await APIService.selectAccountActivity(content: userID);
          }
        }
        _socketResponse.add(accountData);
        print(
            'SOCKET ACCOUNT CHANNEL MSG : $accountData  ${accountData.runtimeType}');
        // 直接在這裡寫進 sqlite
        // if (json.decode(accountData)['ctlmsg'].toString().isNotEmpty &&  json.decode(accountData)['ctlmsg'].toString() == 'friend request'){
        //   print('有人對我發送好友邀請');
        //   print(json.decode(accountData)['account_msg'].toString());
        //   // SqliteHelper.insert(tableName: 'notification', insertData: {});
        //   // insert a notification
        // } else{
        //   print('SOCKET ACCOUNT CHANNEL MSG $accountData');
        // }
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

  Future<void> loginSend() async {
    try {
      _socket.emit('ctlmsg',
          {'ctlmsg': 'join account room', 'account_msg': UserData.userAccount});
    } catch (error) {
      print('ERROR: $error');
    }
  }

  // emit invitation msg to server
  Future<void> friendRequest(String friendAccount) async {
    try {
      _socket.emit('ctlmsg', {
        'ctlmsg': 'friend request',
        'account_msg': UserData.userAccount, // 發邀請者的 account
        'friend_msg': 'john1' // 被邀請者 account
      });
      print('YOU SEND A FRIEND REQUEST TO SOMEBODY');
    } catch (error) {
      print('ERROR: $error');
    }
  }

  // emit invitation msg to server
  Future<void> friendResponse(String friendAccount) async {
    try {
      _socket.emit('ctlmsg', {
        'ctlmsg': 'friend response',
        'friend_msg': 'john1', // 欲邀請好友的 account
        'account_msg': UserData.userAccount // 發邀請者的 account
      });
      print('YOU RESPONSE FRIEND INVITATION TO SOMEBODY');
    } catch (error) {
      print('ERROR: $error');
    }
  }

  // emit invitation msg to server
  Future<void> joinAccountRoom() async {
    try {
      _socket.emit('ctlmsg', {
        'ctlmsg': 'join activity room',
        'activity_msg': '80 money', // 欲邀請好友的 account
        'account_msg': UserData.userAccount // 發邀請者的 account
      });
      print('YOU RESPONSE FRIEND INVITATION TO SOMEBODY');
    } catch (error) {
      print('SOCKET ERROR: $error');
    }
  }

  Future<void> reportActivityInvitation() async {}

  Future<void> reportAlertNotification() async {}

  static Future<void> uploadUserLocation(
      {required String activityMsg, required UserLocation location}) async {
    try {
      _socket.emit('ctlmsg', {
        "ctlmsg": "broadcast location",
        "account_msg": UserData.userAccount,
        "activity_msg": activityMsg,
        "location_msg": {
          "latitude": location.latitude.toString(),
          "longitude": location.longitude.toString(),
          "elevation": location.altitude.toString()
        }
      });
      print('YOU RESPONSE FRIEND INVITATION TO SOMEBODY');
    } catch (error) {
      print('SOCKET ERROR: $error');
    }
  }

  Future<void> dispose() async {
    _socketResponse.close();
    _socket.disconnect();
    _socket.dispose();
    print("SOCKET IO CLIENT CLOSE CONNECTION");
  }

  // static void close() {
  //   _socketResponse.close();
  //   _socket.disconnect().close();
  // }
}
