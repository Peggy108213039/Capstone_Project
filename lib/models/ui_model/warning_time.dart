import 'dart:async';
import 'dart:math';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/services/audio_player.dart';
import 'package:capstone_project/services/stream_socket.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:capstone_project/models/map/user_location.dart';

class WarningTime extends StatefulWidget {
  final bool isStarted;
  final bool isPaused;
  final int checkTime;
  final int warningTime;
  final bool isActivity;
  // final String activityMsg;
  const WarningTime({
    Key? key,
    required this.isStarted,
    required this.isPaused,
    required this.checkTime,
    required this.warningTime,
    required this.isActivity,
    // required this.activityMsg,
  }) : super(key: key);

  @override
  State<WarningTime> createState() => _WarningTimeState();
}

class _WarningTimeState extends State<WarningTime> {
  late bool isStarted;
  late bool isPaused;
  late int checkTime; // 每 checkTime 秒計算一次使用者是否都待在原地
  late int warningTime; // 如果 warningTime 秒內都待在原地，就發出警告

  Timer? checkTimer;
  Timer? sendWarningTimer;
  late bool isActivity;
  // late String activityMsg;

  int stopTimes = 0;
  int distanceRange = 2; // distanceRange 公尺內都算在原地範圍內
  bool isMoved = false; // 使用者是否移動
  ValueNotifier<bool> isVisible = ValueNotifier<bool>(false); // 是否顯示警告訊息

  static UserLocation defaultLocation = UserLocation(
      latitude: 23.94981257,
      longitude: 120.92764976,
      altitude: 572.92668105,
      currentTime: UserLocation.getCurrentTime());
  UserLocation userLocation = defaultLocation;
  UserLocation previousLocation = defaultLocation;

  @override
  void initState() {
    checkTime = widget.checkTime;
    warningTime = widget.warningTime;
    isActivity = widget.isActivity;
    print('警告時間 warningTime : $warningTime     檢查時間 checkTime : $checkTime');
    // activityMsg = widget.activityMsg;
    checkTimer = Timer.periodic(Duration(seconds: checkTime), (timer) {
        if (isStarted && !isPaused) {
          bool isMoved = checkMoved();
          if (isActivity) {
            // print('checkTimer ${timer.tick} 是否移動 $isMoved');
            userStoppedInActivity = !isMoved;
          }
          if (!isMoved) {
            stopTimes++;
            print(
                'checkTimer ${timer.tick} 是否移動 $isMoved stopTimes $stopTimes ');
          }
          previousLocation = userLocation;
        }
      });
      sendWarningTimer =
          Timer.periodic(Duration(seconds: warningTime), (timer) async {
        print('警告計時器 ${timer.tick}  stopTimes $stopTimes');
        if (isStarted && !isPaused) {
          if (stopTimes >= (warningTime / checkTime)) {
            stopTimes = 0;
            isVisible.value = true;
            AudioPlayerService.playAudio(); // 播放警示音
            // print('是不是活動   isActivity  $isActivity');
            if (isActivity) {
              print('傳 SOCKET 訊息');
              await StreamSocket.warningTimeTooLong(
                  activityMsg: activityMsg, location: userLocation);
            }
          }
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    if (checkTimer!.isActive) {
      checkTimer!.cancel();
    }
    if (sendWarningTimer!.isActive) {
      sendWarningTimer!.cancel();
    }
    super.dispose();
  }

  bool checkMoved() {
    double meterDistance = caculateDistance(
            point1: userLocation.toLatLng(),
            point2: previousLocation.toLatLng()) *
        1000;
    if (meterDistance < distanceRange) {
      isMoved = false;
    } else {
      isMoved = true;
      isVisible.value = false;
    }
    return isMoved;
  }

  // 計算三維空間的距離
  double caculateDistance({required LatLng point1, required LatLng point2}) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((point2.latitude - point1.latitude) * p) / 2 +
        cos(point1.latitude * p) *
            cos(point2.latitude * p) *
            (1 - cos((point2.longitude - point1.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    isStarted = widget.isStarted;
    isPaused = widget.isPaused;
    userLocation = Provider.of<UserLocation>(context);

    print(
        'isStarted $isStarted isPaused $isPaused  warningTime   $warningTime checkTime  $checkTime');
    if (!isStarted && !isPaused) {
      isVisible.value = false;
    }

    return ValueListenableBuilder(
      valueListenable: isVisible,
      builder: (context, bool value, child) => Visibility(
        visible: value,
        child: Container(
            width: 180,
            height: 50,
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 173, 150),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: const Center(
              child: Text(
                '在此處停留過久',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            )),
      ),
    );
  }
}
