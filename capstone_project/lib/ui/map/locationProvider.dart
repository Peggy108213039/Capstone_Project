import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/services/location_service.dart';
import 'package:capstone_project/ui/activity/start_activity.dart';
import 'package:capstone_project/ui/map/map_page.dart';
import 'package:capstone_project/ui/map/offline_map/offline_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class LocationProvider extends StatelessWidget {
  final String mapService;
  const LocationProvider({Key? key, required this.mapService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserLocation initData = UserLocation(
        latitude: 23.94981257,
        longitude: 120.92764976,
        altitude: 572.92668105,
        currentTime: UserLocation.getCurrentTime());

    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    List<LatLng> gpsList = [];
    if (arguments['gpsList'] != null) {
      gpsList = arguments['gpsList'];
    }

    Widget service;
    print('呈現地圖服務  $mapService');
    if (mapService == 'StartActivity') {
      service = StartActivity(
        gpsList: gpsList,
      );
    } else if (mapService == 'OfflineMapPage') {
      service = const OfflineMapPage();
      if (arguments['offlineMapData'][0] != null) {
        initData = UserLocation(
            latitude:
                double.parse(arguments['offlineMapData'][0]['centerLatitude']),
            longitude:
                double.parse(arguments['offlineMapData'][0]['centerLongitude']),
            altitude: 572.92668105,
            currentTime: UserLocation.getCurrentTime());
      }
    } else {
      service = const MapPage();
    }
    LocationService.locating();
    LocationService.getLocation;
    return StreamProvider(
      create: (context) => LocationService.locationStream(),
      initialData: initData,
      child: service,
    );
  }
}
