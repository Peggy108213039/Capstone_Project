import 'dart:io';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/track/track_model.dart';
import 'package:capstone_project/services/gpx_service.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/ui/activity/activity_map_widget.dart';
import 'package:capstone_project/ui/activity/warning_distance_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:capstone_project/models/ui_model/input_dialog.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/location_service.dart';

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
  // PolylineCoordinates polyline = PolylineCoordinates();

  // MapController? mapController;
  // double zoomLevel = 16;
  bool isStarted = false;
  bool isPaused = false;

  late MyAlertDialog pauseDialog; // 提醒視窗：暫停紀錄
  late MyAlertDialog dataNotEnoughDialog; // 提醒視窗：軌跡資料不足，無法紀錄
  late MyAlertDialog saveFileSuccessDialog; // 提醒視窗：軌跡檔案儲存成功
  late InputDialog inputTrackNameDialog; // 輸入軌跡名稱

  // location
  // static UserLocation defaultLocation = UserLocation(
  //     latitude: 23.94981257,
  //     longitude: 120.92764976,
  //     altitude: 572.92668105,
  //     currentTime: UserLocation.getCurrentTime());
  // UserLocation currentLocation = defaultLocation; // 預設位置
  // late UserLocation userLocation; // 抓使用者裝置位置

  // List<Marker> _markers = []; // 標記拍照點

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
    // mapController!.dispose();
    LocationService.closeService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    print('===== 建立活動地圖頁面 START =====');
    final List<LatLng> gpsList = widget.gpsList;
    final double warningDistance = double.parse(arguments['warning_distance']);

    // moveCamera();
    // if (isStarted && !isPaused) {
    //   getUserTrack();
    // }

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
        body: Stack(children: [
          ActivityMap(
              gpsList: gpsList, isStarted: isStarted, isPaused: isPaused),
          Center(
            child: WarningDistanceText(
              isStarted: isStarted,
              isPaused: isPaused,
              warningDistance: warningDistance,
              gpsList: gpsList,
            ),
          ),
        ]),
        // FlutterMap(
        //   mapController: mapController,
        //   options: MapOptions(
        //       onMapCreated: _onMapCreated,
        //       zoom: zoomLevel,
        //       center: LatLng(userLocation.latitude, userLocation.longitude)),
        //   layers: [
        //     TileLayerOptions(
        //       urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        //       subdomains: ['a', 'b', 'c'],
        //     ),
        //     MarkerLayerOptions(
        //         markers: _markers +
        //             [
        //               Marker(
        //                   point: LatLng(
        //                       userLocation.latitude, userLocation.longitude),
        //                   builder: (context) => Transform.translate(
        //                         offset: const Offset(-5, -30),
        //                         child: const Icon(
        //                           Icons.location_on,
        //                           size: 50,
        //                           color: Color.fromRGBO(255, 92, 92, 0.922),
        //                         ),
        //                       ))
        //             ]),
        //     PolylineLayerOptions(polylines: [
        //       Polyline(
        //         points: gpsList,
        //         color: Colors.amber,
        //         strokeWidth: 4,
        //       ),
        //       Polyline(
        //         points: polyline.list,
        //         color: Colors.green,
        //         strokeWidth: 4,
        //       )
        //     ])
        //   ],
        // ),
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
                    pushRecordBtn(context);
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

  SizedBox mySpace({required double height, required double num}) {
    return SizedBox(height: (height * num));
  }

  void pushRecordBtn(BuildContext context) async {
    // 剛開始 (預設值)
    if (!isStarted && !isPaused) {
      setState(() {
        isStarted = !isStarted;
      });
      return;
    }
    // 開始後，按暫停 (開始)
    if (isStarted && !isPaused) {
      isPaused = true;
    }
    // 暫停後，確認要繼續或停止紀錄 (暫停)
    if (isStarted && isPaused) {
      pauseDialog = MyAlertDialog(
          context: context,
          titleText: '暫停紀錄軌跡',
          contentText: '',
          btn1Text: '繼續記錄', // true
          btn2Text: '結束紀錄'); // false
      bool? result = await pauseDialog.show();
      while (result != true && result != false) {
        result = await pauseDialog.show();
      }

      isStarted = result!;
      // 如果是停止紀錄
      if (!isStarted && isPaused) {
        // 如果 polyline.userLocationList 沒有 2 個座標
        if (polyline.userLocationList.length < 2) {
          dataNotEnoughDialog = MyAlertDialog(
              context: context,
              titleText: '移動距離太短，無法紀錄',
              contentText: '',
              btn1Text: '確認',
              btn2Text: '');
          await dataNotEnoughDialog.show();
          polyline.clearList(); // 清空 polyline list
          // 切換成開始狀態
          setState(() {
            isStarted = false;
            isPaused = false;
          });
          return;
        }
        // 跳出對話框，讓使用者輸入軌跡名稱
        inputTrackNameDialog = InputDialog(
            context: context,
            myTitle: '新增軌跡資料',
            myContent: '幫你的軌跡取一個名字',
            defaultText: '軌跡名稱',
            inputFieldName: '軌跡名稱',
            btn1Text: '確認',
            btn2Text: '不要儲存軌跡');
        List? result = await inputTrackNameDialog.show();
        // 如果使用者點擊 '確認' 按鈕以外的地方，重新顯示一次 inputTrackNameDialog
        while (result?[0] != true && result?[0] != false) {
          result = await inputTrackNameDialog.show();
        }
        // 確認儲存軌跡
        if (result?[0]) {
          String newName = result?[1];
          String gpxFile = GPXService.writeGPX(
              trackName: newName,
              time: UserLocation.getCurrentTime(),
              userLocationList: polyline.userLocationList);
          String newFilePath = '${trackDir!.path}/$newName.gpx';
          await fileProvider.writeFileAsString(
              content: gpxFile, path: newFilePath);
          bool writeSuccess =
              await fileProvider.fileIsExists(file: File(newFilePath));
          if (writeSuccess) {
            final newTrackData = Track(
              uID: '1',
              tID: '', // FIXME: tID
              track_name: newName,
              track_locate: newFilePath,
              start: polyline.userLocationList[0].currentTime,
              finish: polyline.userLocationList.last.currentTime,
              total_distance: polyline.totalDistance.toStringAsFixed(3),
              time: UserLocation.getCurrentTime(),
              track_type: 'ownTrack',
            ).toMap();
            await SqliteHelper.insert(
                tableName: 'track', insertData: newTrackData);
            saveFileSuccessDialog = MyAlertDialog(
                context: context,
                titleText: '檔案儲存成功',
                contentText: '可以到軌跡頁面查看檔案',
                btn1Text: '確認',
                btn2Text: '');
            await saveFileSuccessDialog.show();
            setState(() {
              isPaused = false;
              isStarted = false;
            });
            return;
          } else {
            print('寫入失敗 writeSuccess $writeSuccess');
          }
        } else {
          print('不要儲存軌跡 result?[0] ${result?[0]}');
        }
        polyline.clearList(); // 清空 polyline list
      } // 如果要繼續記錄
      // 切換成開始狀態
      isPaused = false;
    }
    setState(() {});
  }
}
