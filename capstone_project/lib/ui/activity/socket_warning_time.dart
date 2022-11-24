import 'dart:async';
import 'dart:convert';
import 'package:capstone_project/services/notification_service.dart';
import 'package:flutter/material.dart';

import 'package:capstone_project/services/audio_player.dart';

class SocketWarningTime extends StatefulWidget {
  final bool isStarted;
  final bool isPaused;
  final Object? socketMssege;
  const SocketWarningTime(
      {Key? key,
      required this.isStarted,
      required this.isPaused,
      required this.socketMssege})
      : super(key: key);

  @override
  State<SocketWarningTime> createState() => _SocketWarningTimeState();
}

class _SocketWarningTimeState extends State<SocketWarningTime> {
  late bool isStarted;
  late bool isPaused;
  late Object? socketMssege;

  String warningText = '';
  int showTextTime = 1;
  ValueNotifier<bool> isVisible = ValueNotifier<bool>(false); // 是否顯示警告訊息
  AudioPlayerService audioPlayerService = AudioPlayerService();

  @override
  void dispose() {
    audioPlayerService.close();
    isVisible.dispose();
    super.dispose();
  }

  void changeSocketMsg({required Object? socketMssege}) {
    final tmpSocketData = jsonDecode(jsonEncode(socketMssege!));
    if (tmpSocketData.runtimeType != String) {
      final String ctlMsg = tmpSocketData['ctlmsg'];
      if (ctlMsg == "activity warning") {
        final String wanringMsg = tmpSocketData['wanring_msg'];
        if (wanringMsg == "too long") {
          print('停留時間過久 tmpSocketData $tmpSocketData');
          // FIXME 在 client 顯示 UI 某人停留時間過久
          NotificationService().showNotification(1, 'main_channel', '同行者停留時間過久',
              '${tmpSocketData['account_msg']} 停留時間過久\n${tmpSocketData['location_msg']}');
          warningText +=
              '${tmpSocketData['account_msg']} 停留時間過久\n${tmpSocketData['location_msg']}';
          isVisible.value = true;
          audioPlayerService.playAudio();
          Timer(Duration(seconds: showTextTime), () {
            isVisible.value = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    isStarted = widget.isStarted;
    isPaused = widget.isPaused;
    socketMssege = widget.socketMssege;
    if (isStarted && !isPaused) {
      // 依照 socket 傳來的訊息做顯示
      changeSocketMsg(socketMssege: socketMssege);
    }
    if (!isStarted && !isPaused) {
      isVisible.value = false;
    }
    return ValueListenableBuilder(
        valueListenable: isVisible,
        builder: (context, bool value, child) => Visibility(
            visible: value,
            child: Container(
                width: 300,
                height: 150,
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 246, 150),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Center(
                  child: Text(
                    warningText,
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ))));
  }
}
