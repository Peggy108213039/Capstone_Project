import 'dart:convert';

import 'package:capstone_project/services/stream_socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/services/cache_tile_provider.dart';

class ActivityMap extends StatefulWidget {
  final List<LatLng> gpsList;
  final bool isStarted;
  final bool isPaused;
  final List<Marker> markerList; // 標記拍照點
  final bool sharePosition; // 使用者是否想要分享位置
  final String activityMsg; // socket 的 activityMsg
  const ActivityMap(
      {Key? key,
      required this.gpsList,
      required this.isStarted,
      required this.isPaused,
      required this.markerList,
      required this.sharePosition,
      required this.activityMsg})
      : super(key: key);

  @override
  State<ActivityMap> createState() => _ActivityMapState();
}

class _ActivityMapState extends State<ActivityMap> {
  MapController? mapController;
  late List<LatLng> gpsList;
  late bool isStarted;
  late bool isPaused;
  late List<Marker> markerList;
  late bool sharePosition;
  late String activityMsg;

  static UserLocation defaultLocation = UserLocation(
      latitude: 23.94981257,
      longitude: 120.92764976,
      altitude: 572.92668105,
      currentTime: UserLocation.getCurrentTime());
  UserLocation currentLocation = defaultLocation;
  UserLocation userLocation = defaultLocation;

  double zoomLevel = 16;

  @override
  void initState() {
    gpsList = widget.gpsList;
    sharePosition = widget.sharePosition;
    activityMsg = widget.activityMsg;
    super.initState();
  }

  @override
  void dispose() {
    mapController!.dispose();
    polyline.clearList();
    super.dispose();
  }

  // 抓使用者目前位置
  Future<void> moveCamera(
      {required UserLocation userLocation,
      required UserLocation currentLocation}) async {
    currentLocation = userLocation;
    // 當使用者的位置移動時，地圖的 camera 要跟著移動
    if (mapController != null) {
      mapController!.move(currentLocation.toLatLng(), zoomLevel);
    }
  }

  Future<void> _onMapCreated(MapController controller) async {
    mapController = controller;
  }

  // 畫使用者的軌跡
  void getUserTrack({required List<LatLng> gpsList}) async {
    if (isStarted && !isPaused) {
      polyline.recordCoordinates(userLocation);
      print('polyline 我的軌跡 ${polyline.list}');

      // FIXME 傳自己的座標給 server
      if (sharePosition) {
        print(activityMsg);
        StreamSocket.uploadUserLocation(
            activityMsg: activityMsg, location: userLocation);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    isStarted = widget.isStarted;
    isPaused = widget.isPaused;
    userLocation = Provider.of<UserLocation>(context);
    markerList = widget.markerList;
    print('activityMsg $activityMsg');
    if (userLocation != currentLocation) {
      moveCamera(userLocation: userLocation, currentLocation: currentLocation);
    }

    if (isStarted && !isPaused) {
      getUserTrack(gpsList: gpsList);
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
          onMapCreated: _onMapCreated,
          zoom: zoomLevel,
          center: LatLng(userLocation.latitude, userLocation.longitude)),
      layers: [
        TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            tileProvider: CachedTileProvider()),
        MarkerLayerOptions(
            markers: markerList +
                [
                  Marker(
                      point:
                          LatLng(userLocation.latitude, userLocation.longitude),
                      builder: (context) => Transform.translate(
                            offset: const Offset(-5, -30),
                            child: const Icon(
                              Icons.location_on,
                              size: 50,
                              color: Color.fromRGBO(255, 92, 92, 0.922),
                            ),
                          ))
                ]),
        // FIXME 將同行者的 polyline 加進來
        PolylineLayerOptions(polylines: [
          Polyline(
            points: gpsList,
            color: Colors.amber,
            strokeWidth: 4,
          ),
          Polyline(
            points: polyline.list,
            color: Colors.green,
            strokeWidth: 4,
          )
        ])
      ],
    );
  }
}
