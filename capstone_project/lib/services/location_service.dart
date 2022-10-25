import 'dart:async';
import 'package:capstone_project/models/map/user_location.dart';
import 'package:location/location.dart';
import 'dart:io';

class LocationService {
  // static int sleepTime = 10;
  static double updateDistancce = 5; // 每 5 公尺更新一次距離
  static int updateInterval = 3000; // 每 3 秒更新一次距離

  // 使用者目前位置
  static late UserLocation currentLocation;

  static Location location = Location();

  static bool isFirstLocated = true;

  // 持續監聽使用者位置
  static StreamController<UserLocation>? _locationController;

  static late StreamSubscription<LocationData> locationSubscription;

  static Future<void> locating() async {
    // 每 5 公尺移動一次位置
    await location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: updateInterval,
        distanceFilter: updateDistancce);

    print('誰先 ? locating');
    location.requestPermission().then((PermissionStatus value) {
      if (value == PermissionStatus.granted) {
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
      }
    });
  }

  static void addLocationData(LocationData locationData) {
    if (_locationController!.isClosed) {
      print('定位服務已關閉');
      return;
    }
    _locationController?.add(UserLocation(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        altitude: locationData.altitude!,
        currentTime: UserLocation.getCurrentTime()));
    print(
        '使用者位置 經度 : ${locationData.latitude!} 緯度 : ${locationData.longitude!}');
  }

  static Stream<UserLocation> locationStream() {
    _locationController = StreamController<UserLocation>.broadcast();
    return _locationController!.stream;
  }

  static Future<UserLocation?> get getLocation async {
    try {
      print('誰先 ? getLocation');
      var userLocation = await location.getLocation();
      currentLocation = UserLocation(
          latitude: userLocation.latitude!,
          longitude: userLocation.longitude!,
          altitude: userLocation.altitude!,
          currentTime: UserLocation.getCurrentTime());
      print('current location 目前位置 $currentLocation');
    } catch (err) {
      print('Could not get the locationn\n $err');
    }
    return currentLocation;
  }

  static void closeService() {
    _locationController!.close();
    locationSubscription.cancel();
    print('===== 關掉訂位服務 =====');
    return;
  }
}
