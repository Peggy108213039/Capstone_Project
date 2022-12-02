import 'dart:async';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/services/stream_socket.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:math';
import 'package:capstone_project/services/audio_player.dart';

class LocationService {
  // static int sleepTime = 10;
  static double updateDistancce = 2; // 每 2 公尺更新一次距離
  static int updateInterval = 5000; // 每 5 秒更新一次距離

  // 使用者目前位置
  static late UserLocation currentLocation;
  static Location location = Location();
  static bool isFirstLocated = true;

  // 持續監聽使用者位置
  static StreamController<UserLocation>? _locationController;
  static StreamSubscription<LocationData>? locationSubscription;

  static Future<void> locating() async {
    // 確認定位服務是否被開啟
    bool _serviceEnabled = await location.serviceEnabled();
    print('要求定位權限 1 $_serviceEnabled');
    if (!_serviceEnabled) {
      // 要求定位權限
      _serviceEnabled = await location.requestService();
      print('要求定位權限 2  $_serviceEnabled');
      if (!_serviceEnabled) {
        return;
      }
    }

    PermissionStatus _permissionGranted = await _getLocationPermission();

    if (_permissionGranted == PermissionStatus.granted) {
      try {
        // 在背景程式使用定位服務
        await location.enableBackgroundMode(enable: true);
        await location.changeSettings(
            accuracy: LocationAccuracy.high,
            interval: updateInterval,
            distanceFilter: updateDistancce);
        locationSubscription =
            location.onLocationChanged.listen((locationData) {
          if (!isFirstLocated) {
            if (_locationController != null) {
              addLocationData(locationData);
            }
          } else {
            isFirstLocated = false;
            addLocationData(locationData);
          }
        });
      } catch (error) {
        print('LocationService 定位服務報錯   $error');
        return;
      }
    } else {
      return;
    }
  }

  static Future<PermissionStatus> _getLocationPermission() async {
    // 確認 APP 有同意開啟定位服務
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      // 要求開啟權限
      final PermissionStatus permissionStatus =
          await location.requestPermission();
      print('要求 APP 開啟權限 1 $permissionStatus');
      return permissionStatus;
    } else {
      print('要求 APP 開啟權限 2 $_permissionGranted');
      return _permissionGranted;
    }
  }

  static void addLocationData(LocationData locationData) {
    if (_locationController!.isClosed) {
      print('定位服務已關閉');
      return;
    }
    if (!_locationController!.isClosed) {
      _locationController?.add(UserLocation(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          altitude: locationData.altitude!,
          currentTime: UserLocation.getCurrentTime()));
    }
    // print(
    //     '使用者位置 經度 : ${locationData.latitude!} 緯度 : ${locationData.longitude!}');
    if (mapIsBackground) {
      if (mapIsStarted && !mapIsPaused) {
        mapPolyline.recordCoordinates(userLocation);
      }
    }

    if (activityIsBackground) {
      if (activityIsStarted && !activityIsPaused) {
        activPolyline.recordCoordinates(userLocation);
        caculateWarningDistance(
            warningDistance: activityWarningDistance, gpsList: activityGpsList);
        // 傳自己的座標給 server
        if (activitySharePosition) {
          print(activityMsg);
          StreamSocket.uploadUserLocation(
              activityMsg: activityMsg,
              warningDistance: activityWarningDistance,
              location: userLocation);
        }
      }
    }
  }

  static Stream<UserLocation> locationStream() {
    _locationController = StreamController<UserLocation>.broadcast();
    return _locationController!.stream;
  }

  static Future<UserLocation?> get getLocation async {
    try {
      LocationData userLocation = await location.getLocation();
      currentLocation = UserLocation(
          latitude: userLocation.latitude!,
          longitude: userLocation.longitude!,
          altitude: userLocation.altitude!,
          currentTime: UserLocation.getCurrentTime());
    } catch (err) {
      print('Could not get the locationn\n $err');
    }
    return currentLocation;
  }

  static void closeService() {
    if (_locationController != null) {
      _locationController!.close();
    }
    if (locationSubscription != null) {
      locationSubscription!.cancel();
    }
    print('===== 關掉訂位服務 =====');
    return;
  }

  static List inSafeDistance(
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

  // 計算三維空間的距離
  static double caculateDistance(
      {required LatLng point1, required LatLng point2}) {
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
  static void caculateWarningDistance(
      {required double warningDistance, required List<LatLng> gpsList}) async {
    inSafeDistance(
        warningDistance: warningDistance,
        currentPoint: LatLng(userLocation.latitude, userLocation.longitude),
        pointList: gpsList);
  }
}
