// 2022/11/15 已合併至 stream_socket.dart

import 'package:capstone_project/services/http_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService{
  final IO.Socket socket = IO.io('http://163.22.17.247:3000', IO.OptionBuilder()
    .setAuth({'account': UserData.userAccount})
    .setTransports(['websocket'])
    .build());
  var myAccount = UserData.userAccount;

  Future<void> connectAndListen() async { 
    print('CONNECT AND LISTEN');
    try {
      socket.connect();
      print("CONNECTING");
      socket.onConnect((_) {
        print('CONNECTION ESTABLISHED');
      });
      // 監聽頻道
      socket.on('account', (accountData) => print('SOCKET ACCOUNT CHANNEL MSG：$accountData'));
      socket.on('activity', (activityData) => print('SOCKET ACTIVITY CHANNEL MSG：$activityData'));
    } catch(error){
      print('ERROR : $error');
    }
  }

  Future<void> loginSend() async {
    try {
      socket.emit('ctlmsg', {
        'ctlmsg': 'join account room',
        'account_msg': UserData.userAccount
      });
    } catch(error) {
      print('ERROR: $error');
    }
  }

  // emit invitation msg to server
  Future<void> friendRequest(String friendAccount) async{
    try {
      socket.emit('ctlmsg', {
        'ctlmsg': 'friend request',
        'account_msg': UserData.userAccount, // 發邀請者的 account
        'friend_msg': 'john1' // 被邀請者 account
      });
      print('YOU SEND A FRIEND REQUEST TO SOMEBODY');
    } catch(error) {
      print('ERROR: $error');
    }
  }

  // emit invitation msg to server
  Future<void> friendResponse(String friendAccount) async{
    try {
      socket.emit('ctlmsg', {
        'ctlmsg': 'friend response',
        'friend_msg': 'john1', // 欲邀請好友的 account
        'account_msg': UserData.userAccount // 發邀請者的 account
      });
      print('YOU RESPONSE FRIEND INVITATION TO SOMEBODY');
    } catch(error) {
      print('ERROR: $error');
    }
  }

  // emit invitation msg to server
  Future<void> joinAccountRoom() async{
    try {
      socket.emit('ctlmsg', {
        'ctlmsg': 'join activity room',
        'activity_msg': '80 money', // 欲邀請好友的 account
        'account_msg': UserData.userAccount // 發邀請者的 account
      });
      print('YOU RESPONSE FRIEND INVITATION TO SOMEBODY');
    } catch(error) {
      print('SOCKET ERROR: $error');
    }
  }

  Future<void> reportActivityInvitation() async{

  }

  Future<void> reportAlertNotification() async{

  }

  Future<void> dispose() async {
    socket.disconnect();
    socket.dispose();
    print("SOCKET IO CLIENT CLOSE CONNECTION");
  }
}