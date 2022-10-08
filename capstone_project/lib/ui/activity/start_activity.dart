import 'dart:io';
import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/services/PolylineCoordinates_model.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class StartActivity extends StatefulWidget {
  final List<LatLng> gpsList;
  const StartActivity({Key? key, required this.gpsList}) : super(key: key);

  @override
  State<StartActivity> createState() => _StartActivityState();
}

class _StartActivityState extends State<StartActivity> {
  late Directory? trackDir; // 軌跡資料夾
  final FileProvider fileProvider = FileProvider();
  // 紀錄使用者的 polyline
  PolylineCoordinates polyline = PolylineCoordinates();

  MapController? mapController;
  double zoomLevel = 16;
  bool isStarted = false;
  bool isPaused = false;

  // location
  static UserLocation defaultLocation = UserLocation(
      latitude: 23.94981257,
      longitude: 120.92764976,
      altitude: 572.92668105,
      currentTime: UserLocation.getCurrentTime());
  UserLocation currentLocation = defaultLocation; // 預設位置
  late UserLocation userLocation; // 抓使用者裝置位置

  List<Marker> _markers = []; // 標記拍照點

  // button style
  final raisedBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(55, 55),
      shape: const CircleBorder(),
      backgroundColor: Colors.indigoAccent.shade100);
  final startBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(55, 55),
      shape: const CircleBorder(),
      backgroundColor: Colors.teal);
  final stopBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(55, 55),
      shape: const CircleBorder(),
      backgroundColor: Colors.red);

  @override
  void initState() {
    getTrackDirPath();
    super.initState();
  }

  @override
  void dispose() {
    print('===== 刪掉 dispose =====');
    mapController!.dispose();
    LocationService.closeService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('===== 建立活動地圖頁面 =====');
    userLocation = Provider.of<UserLocation>(context);
    final List<LatLng> gpsList = widget.gpsList;
    print('==============\nGPS LIST  $gpsList');

    moveCamera();
    if (isStarted && !isPaused) {
      getUserTrack();
    }

    // 抓使用者手機螢幕的高
    double height = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('開始紀錄活動')),
          backgroundColor: Colors.indigoAccent.shade100,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: '返回',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
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
            ),
            MarkerLayerOptions(
                markers: _markers +
                    [
                      Marker(
                          point: LatLng(
                              userLocation.latitude, userLocation.longitude),
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
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      print('拍照');
                    },
                    child: const Icon(Icons.camera_alt_outlined),
                    style: raisedBtnStyle,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('離線地圖');
                    },
                    child: const Icon(Icons.map),
                    style: raisedBtnStyle,
                  )
                ],
              ),
            ),
            mySpace(height: height, num: 0.01),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      print('AR 按鈕');
                    },
                    child: const Text(
                      'AR',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: raisedBtnStyle,
                  ),
                  // FIXME
                  // ElevatedButton(
                  //   onPressed: () {
                  //     print('切換地圖圖層按鈕');
                  //   },
                  //   child: const Text(
                  //     '地圖\n圖層',
                  //     style: TextStyle(fontSize: 15),
                  //   ),
                  //   style: raisedBtnStyle,
                  // )
                ],
              ),
            ),
            mySpace(height: height, num: 0.035),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('記錄軌跡按鈕');
                  },
                  child: isStarted
                      ? const Icon(
                          Icons.stop_rounded,
                          size: 42.0,
                        )
                      : const Icon(
                          Icons.play_arrow_rounded,
                          size: 42.0,
                        ),
                  style: isStarted ? stopBtnStyle : startBtnStyle,
                ),
              ],
            ),
            mySpace(height: height, num: 0.05),
          ],
        ),
      ),
    );
  }

  Future<void> getTrackDirPath() async {
    // 抓此 APP 的檔案路徑
    await fileProvider.getAppPath;
    // 抓軌跡資料夾
    trackDir = await fileProvider.getSpecificDir(dirName: 'trackData');
    print("trackDir path : ${trackDir!.path}");
  }

  // 抓使用者目前位置
  Future<void> moveCamera() async {
    if (userLocation != currentLocation) {
      print("================== 目前位置改變，相機移動 ==================");
      currentLocation = userLocation;
      // 當使用者的位置移動時，地圖的 camera 要跟著移動
      if (mapController != null) {
        mapController?.move(currentLocation.toLatLng(), zoomLevel);
      }
    }
  }

  // 畫使用者的軌跡
  void getUserTrack() async {
    if (isStarted && !isPaused) {
      if (userLocation == defaultLocation) {
        return;
      }
      polyline.recordCoordinates(userLocation);
    }
  }

  SizedBox mySpace({required double height, required double num}) {
    return SizedBox(height: (height * num));
  }

  Future<void> _onMapCreated(MapController controller) async {
    mapController = controller;
  }
}
