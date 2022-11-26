import 'package:capstone_project/constants.dart';
import 'package:capstone_project/services/audio_player.dart';
import 'package:capstone_project/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:capstone_project/models/map/user_location.dart';

class WarningDistanceText extends StatefulWidget {
  final bool isStarted;
  final bool isPaused;
  final double warningDistance;
  final List<LatLng> gpsList;
  const WarningDistanceText({
    Key? key,
    required this.isStarted,
    required this.isPaused,
    required this.gpsList,
    required this.warningDistance,
  }) : super(key: key);

  @override
  State<WarningDistanceText> createState() => _WarningDistanceTextState();
}

class _WarningDistanceTextState extends State<WarningDistanceText> {
  late bool isStarted;
  late bool isPaused;
  static UserLocation defaultLocation = UserLocation(
      latitude: 23.94981257,
      longitude: 120.92764976,
      altitude: 572.92668105,
      currentTime: UserLocation.getCurrentTime());
  UserLocation userLocation = defaultLocation;
  late List<LatLng> gpsList;
  late double warningDistance;

  bool isVisible = false;
  String warningDistanceString = '';

  @override
  void initState() {
    warningDistance = widget.warningDistance;
    activityWarningDistance = warningDistance;
    gpsList = widget.gpsList;
    activityGpsList = gpsList;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  List inSafeDistance(
      {required double warningDistance,
      required LatLng currentPoint,
      required List<LatLng> pointList}) {
    List<double> distanceList = [];
    if (pointList.isNotEmpty) {
      // 計算與所有點的距離
      for (int i = 0; i < pointList.length; i++) {
        double tempDistance =
            caculateDistance(point1: currentPoint, point2: pointList[i]);
        distanceList.add(tempDistance);
        if (tempDistance * 1000 < warningDistance) {
          return [true, tempDistance];
        }
      }
    }
    distanceList.sort();
    // FIXME 警示音
    AudioPlayerService.playAudio();
    return [false, distanceList[0]];
  }

  // 計算警告距離
  void caculateWarningDistance(
      {required double warningDistance, required List<LatLng> gpsList}) async {
    List result = inSafeDistance(
        warningDistance: warningDistance,
        currentPoint: LatLng(userLocation.latitude, userLocation.longitude),
        pointList: gpsList);
    bool inSafe = result[0];
    if (!inSafe) {
      isVisible = true;
      double minDistance = result[1];
      if (minDistance < 1) {
        double distance = double.parse((minDistance * 1000).toStringAsFixed(2));
        warningDistanceString = '偏離軌跡\n距離軌跡 $distance 公尺';
      } else {
        double distance = double.parse(minDistance.toStringAsFixed(2));
        warningDistanceString = '偏離軌跡\n距離軌跡 $distance 公里';
      }
    } else {
      isVisible = false;
      warningDistanceString = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    userLocation = Provider.of<UserLocation>(context);
    isStarted = widget.isStarted;
    isPaused = widget.isPaused;

    if (isStarted && !isPaused) {
      caculateWarningDistance(
          warningDistance: warningDistance, gpsList: gpsList);
    }
    if (!isStarted && !isPaused) {
      isVisible = false;
    }

    return Visibility(
      visible: isVisible,
      child: Container(
          width: 200,
          height: 80,
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 229, 150),
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Center(
            child: Text(
              warningDistanceString,
              style: const TextStyle(color: Colors.black, fontSize: 15),
            ),
          )),
    );
  }
}
