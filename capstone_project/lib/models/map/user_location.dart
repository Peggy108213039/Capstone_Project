import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:map_elevation/map_elevation.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final double altitude;
  final String currentTime;

  UserLocation(
      {required this.latitude,
      required this.longitude,
      required this.altitude,
      required this.currentTime});

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  ElevationPoint toElevationPoint() {
    return ElevationPoint(latitude, longitude, altitude);
  }

  static String getCurrentTime() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  }
}
