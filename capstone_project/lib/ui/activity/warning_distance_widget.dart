import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:capstone_project/constants.dart';
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

  String warningDistanceString = '';

  @override
  void initState() {
    warningDistance = widget.warningDistance;
    gpsList = widget.gpsList;
    super.initState();
  }

  // 過濾點 (如果 warningDistance 內有點的話，代表沒有偏離)
  bool filterPoint(
      {required double warningDistance,
      required LatLng currentPoint,
      required List<LatLng> pointList}) {
    double meterToLongitudeDegree = 1 / 111120; // 一公尺 = 多少度 (longitude 經度)
    double meterToLatitudeDegree =
        1 / 111319.488 * cos(currentPoint.latitude); // 一公尺 = 多少度 (latitude 緯度)
    double lanMeter = (warningDistance / 2) * meterToLatitudeDegree; // 緯度
    double lonMeter = (warningDistance / 2) * meterToLongitudeDegree; // 經度
    double tempEastPoint = currentPoint.latitude + lanMeter;
    double tempWestPoint = currentPoint.latitude - lanMeter;
    double tempNorthPoint = currentPoint.longitude + lonMeter;
    double tempSouthPoint = currentPoint.longitude - lonMeter;
    List<double> lanList = [tempEastPoint, tempWestPoint];
    List<double> lonList = [tempNorthPoint, tempSouthPoint];
    lanList.sort();
    lonList.sort();
    if (pointList.isNotEmpty) {
      for (int i = 0; i < pointList.length; i++) {
        if (pointList[i].latitude >= lanList.first &&
            pointList[i].latitude <= lanList.last) {
          if (pointList[i].longitude >= lonList.first &&
              pointList[i].longitude <= lonList.last) {
            // 紀錄上一個點
            previousPoint = pointList[i];
            havePreviousPoint = true;
            return true;
          }
        }
      }
      return false;
    }
    // pointList is Empty
    return false;
  }

  // 計算與所有點的距離
  List userWithAllPointsDistance(LatLng currentPoint, List<LatLng> pointList) {
    List distanceList = [];
    late double tempDistance;
    for (int i = 0; i < pointList.length; i++) {
      tempDistance =
          caculateDistance(point1: currentPoint, point2: pointList[i]);
      distanceList.add(tempDistance);
    }
    return distanceList;
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

// 計算警告距離
  void caculateWarningDistance(
      {required double warningDistance, required List<LatLng> gpsList}) async {
    if (isStarted && !isPaused) {
      bool havePoint = filterPoint(
          warningDistance: warningDistance,
          currentPoint: LatLng(userLocation.latitude, userLocation.longitude),
          pointList: gpsList);
      if (!havePoint) {
        late double minDistance;
        // 如果沒有上一個點，計算與所有點的距離，並回傳最小值
        if (!havePreviousPoint) {
          List result = userWithAllPointsDistance(
              LatLng(userLocation.latitude, userLocation.longitude), gpsList);
          result.sort();
          minDistance = result[0];
        } else {
          // 計算與 previousPoint 的位置，並回傳距離
          minDistance = caculateDistance(
              point1: LatLng(userLocation.latitude, userLocation.longitude),
              point2: previousPoint);
        }
        if (minDistance < 1) {
          double distance =
              double.parse((minDistance * 1000).toStringAsFixed(2));
          warningDistanceString = '1 偏離軌跡\n距離軌跡最近距離為 $distance 公尺';
        } else {
          double distance = double.parse(minDistance.toStringAsFixed(2));
          warningDistanceString = '2 偏離軌跡\n距離軌跡最近距離為 $distance 公里';
        }
      } else {
        warningDistanceString = '';
      }
    }
    print('warningDistanceString $warningDistanceString');
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

    return Text(warningDistanceString);
  }
}
