import 'dart:async';
import 'package:capstone_project/services/http_service.dart';
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

  static void connectAndListen() {
    print('CONNECT AND LISTEN');
    try {
      _socket.connect();
      print("CONNECTING");
      _socket.onConnect((_) {
        print('CONNECTION ESTABLISHED');
      });
      // 監聽頻道
      _socket.on('account', (accountData) {
        _socketResponse.add(accountData);
        print(
            'SOCKET ACCOUNT CHANNEL MSG：$accountData  ${accountData.runtimeType}');
      });
      _socket.on('activity', (activityData) {
        _socketResponse.add(activityData);
        print('SOCKET ACTIVITY CHANNEL MSG：$activityData');
      });
    } catch (error) {
      print('ERROR :\n$error');
    }
  }

  static void close() {
    _socketResponse.close();
    _socket.disconnect().close();
  }
}
