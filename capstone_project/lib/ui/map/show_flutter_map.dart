import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/services/cache_tile_provider.dart';
import 'package:capstone_project/services/polyline_coordinates_model.dart';

class ShowFlutterMap extends StatefulWidget {
  final bool isStarted;
  final bool isPaused;
  final PolylineCoordinates polyline;
  final List<Marker> markerList; // 標記拍照點
  const ShowFlutterMap(
      {Key? key,
      required this.isStarted,
      required this.isPaused,
      required this.polyline,
      required this.markerList})
      : super(key: key);

  @override
  State<ShowFlutterMap> createState() => _ShowFlutterMapState();
}

class _ShowFlutterMapState extends State<ShowFlutterMap> {
  MapController? mapController;
  late bool isStarted;
  late bool isPaused;
  late PolylineCoordinates polyline; // 紀錄使用者的 polyline
  late List<Marker> markerList;
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
    // gpsList = widget.gpsList;
    super.initState();
  }

  @override
  void dispose() {
    mapController!.dispose();
    // polyline.clearList();
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
  void getUserTrack() async {
    if (isStarted && !isPaused) {
      polyline.recordCoordinates(userLocation);
      print('polyline 我的軌跡 ${polyline.list}');
    }
  }

  @override
  Widget build(BuildContext context) {
    userLocation = Provider.of<UserLocation>(context);
    isStarted = widget.isStarted;
    isPaused = widget.isPaused;
    polyline = widget.polyline;
    markerList = widget.markerList;

    if (userLocation != currentLocation) {
      moveCamera(userLocation: userLocation, currentLocation: currentLocation);
    }

    if (isStarted && !isPaused) {
      getUserTrack();
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
        PolylineLayerOptions(polylines: [
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
