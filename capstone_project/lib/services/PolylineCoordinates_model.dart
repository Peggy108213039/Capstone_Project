import 'dart:math';

import 'package:capstone_project/models/map/user_location.dart';
import 'package:latlong2/latlong.dart';

class PolylineCoordinates {
  late List<LatLng> list;
  late List<UserLocation> userLocationList;

  PolylineCoordinates() {
    list = [];
    userLocationList = [];
  }
  //

  // 紀錄目前軌跡
  void recordCoordinates(UserLocation location) {
    list.add(location.toLatLng());
    userLocationList.add(UserLocation(
        latitude: location.latitude,
        longitude: location.longitude,
        altitude: location.altitude,
        currentTime: UserLocation.getCurrentTime()));
  }

  // 計算三維空間的距離
  double caculateDistance(
      {required UserLocation point1, required UserLocation point2}) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((point2.latitude - point1.latitude) * p) / 2 +
        cos(point1.latitude * p) *
            cos(point2.latitude * p) *
            (1 - cos((point2.longitude - point1.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  void clearList() {
    list.clear();
    userLocationList.clear();
    print('list $list');
    print('userLocationList $userLocationList');
  }

  // 計算使用者移動的總距離 (list)
  double get totalDistance {
    double distance = 0;
    for (var i = 0; i < userLocationList.length - 1; i++) {
      distance += caculateDistance(
          point1: userLocationList[i], point2: userLocationList[i + 1]);
    }
    return distance;
  }
}
