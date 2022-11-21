import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
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

class _ShowFlutterMapState extends State<ShowFlutterMap>
    with WidgetsBindingObserver {
  MapController? mapController;
  late bool isStarted;
  late bool isPaused;
  late PolylineCoordinates polyline; // 紀錄使用者的 polyline
  late List<Marker> markerList;
  late MyAlertDialog takePhotoDialog; // 提醒視窗：照片儲存成功
  double zoomLevel = 16;
  bool isFirstTime = true;

  // button style
  final raisedBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(50, 50),
      shape: const CircleBorder(),
      backgroundColor: darkGreen1);

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mapController!.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('========\nstate = $state\n========');
    if (state == AppLifecycleState.inactive || // 可見、不可操作
            state == AppLifecycleState.paused || // 不可見、不可操作（進入背景）
            state == AppLifecycleState.detached // 雖然還在運行，但已經沒有任何存在的頁面
        ) {
      mapIsBackground = true;
    } else {
      mapIsBackground = false;
    }
    print('地圖在背景 mapIsBackground');
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
      print('polyline 我的軌跡 ${polyline.list.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 去抓使用者手機螢幕的高
    double height = MediaQuery.of(context).size.height;

    userLocation = Provider.of<UserLocation>(context);
    isStarted = widget.isStarted;
    isPaused = widget.isPaused;
    polyline = widget.polyline;
    markerList = widget.markerList;

    // FIXME 地圖畫面自動跳到使用者當前位置
    // if (userLocation != currentLocation) {
    //   moveCamera(userLocation: userLocation, currentLocation: currentLocation);
    // }

    if (isStarted && !isPaused) {
      getUserTrack();
    }

    return Scaffold(
      body: FlutterMap(
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
                      width: 15,
                      height: 15,
                      builder: (context) => Container(
                        decoration: BoxDecoration(
                            color: isStarted ? Colors.red : Colors.indigoAccent,
                            shape: BoxShape.circle,
                            border: Border.all(width: 3, color: Colors.white)),
                      ),
                    )
                  ]),
          PolylineLayerOptions(polylines: [
            Polyline(
              points: polyline.list,
              color: Colors.green,
              strokeWidth: 4,
            )
          ])
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: '回到目前位置',
                  child: ElevatedButton(
                    onPressed: () {
                      if (userLocation != currentLocation) {
                        moveCamera(
                            userLocation: userLocation,
                            currentLocation: currentLocation);
                      }
                    },
                    child: const Icon(
                      Icons.gps_fixed,
                      size: 28,
                    ),
                    style: raisedBtnStyle,
                  ),
                )
              ],
            ),
          ),
          mySpace(num: 0.085, height: height)
        ],
      ),
    );
  }

  SizedBox mySpace({required double num, required double height}) {
    return SizedBox(height: (height * num + 60));
  }
}
