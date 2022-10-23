import 'dart:io';

import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/models/track/track_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:capstone_project/models/ui_model/input_dialog.dart';
import 'package:capstone_project/services/PolylineCoordinates_model.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/gpx_service.dart';
import 'package:capstone_project/services/location_service.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:provider/provider.dart';

class FlutterMapPage extends StatefulWidget {
  const FlutterMapPage({Key? key}) : super(key: key);

  @override
  State<FlutterMapPage> createState() => _FlutterMapPageState();
}

class _FlutterMapPageState extends State<FlutterMapPage> {
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

  final FileProvider fileProvider = FileProvider();
  // 紀錄使用者的 polyline
  PolylineCoordinates polyline = PolylineCoordinates();

  // button style
  final raisedBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(55, 55),
      shape: const CircleBorder(),
      backgroundColor: darkGreen2);
  final startBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(55, 55),
      shape: const CircleBorder(),
      backgroundColor: Colors.teal);
  final stopBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(55, 55),
      shape: const CircleBorder(),
      backgroundColor: Colors.red);

  late MyAlertDialog pauseDialog; // 提醒視窗：暫停紀錄
  late MyAlertDialog dataNotEnoughDialog; // 提醒視窗：軌跡資料不足，無法紀錄
  late MyAlertDialog saveFileSuccessDialog; // 提醒視窗：軌跡檔案儲存成功
  late MyAlertDialog takePhotoDialog; // 提醒視窗：照片儲存成功
  late InputDialog inputTrackNameDialog; // 輸入軌跡名稱
  late Directory? trackDir; // 軌跡資料夾

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
    print('===== 建立地圖頁面 =====');
    userLocation = Provider.of<UserLocation>(context);
    moveCamera();
    if (isStarted && !isPaused) {
      getUserTrack();
    }
    // 去抓使用者手機螢幕的高
    double height = MediaQuery.of(context).size.height;

    SizedBox mySpace(double num) {
      return SizedBox(height: (height * num));
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('地圖頁面')),
          backgroundColor: darkGreen1,
        ),
        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            onMapCreated: _onMapCreated,
            zoom: zoomLevel,
            center: LatLng(userLocation.latitude, userLocation.longitude),
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            // MarkerLayerOptions(markers: _markers),
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
                              )),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/AR'),
                      // child: const Icon(Icons.camera_alt_outlined),
                      child: const ImageIcon(arIcon),
                      style: raisedBtnStyle,
                    ),
                  ],
                ),
              ),
              mySpace(0.06),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => takePhoto(_markers),
                      // child: const Icon(Icons.camera_alt_outlined),
                      child: const ImageIcon(cameraIcon),
                      style: raisedBtnStyle,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print('離線地圖清單');
                        Navigator.pushNamed(context, '/TestOfflineMap');
                      },
                      child: const ImageIcon(layerIcon),
                      style: raisedBtnStyle,
                    ),
                  ],
                ),
              ),
              mySpace(0.06),
              // 紀錄軌跡按鈕
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => pushRecordBtn(context),
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
                  ]),
              mySpace(0.025)
            ]),
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
                    tID: '', // FIXME: tID
                    uID: '1',
                    track_name: newName,
                    track_locate: newFilePath,
                    start: polyline.userLocationList[0].currentTime,
                    finish: polyline.userLocationList.last.currentTime,
                    total_distance: polyline.totalDistance.toStringAsFixed(3),
                    time: UserLocation.getCurrentTime(),
                    track_type: 'ownTrack')
                .toMap();
            await SqliteHelper.insert(
                tableName: 'track', insertData: newTrackData);
            saveFileSuccessDialog = MyAlertDialog(
                context: context,
                titleText: '檔案儲存成功',
                contentText: '可以到軌跡頁面查看檔案',
                btn1Text: '確認',
                btn2Text: '');
            saveFileSuccessDialog.show();
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

  Future<void> _onMapCreated(MapController controller) async {
    mapController = controller;
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
      polyline.recordCoordinates(userLocation);
    }
  }

  void takePhoto(List<Marker> _markers) async {
    File? imageFile;
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    imageFile = File(pickedFile!.path);
    // 存到手機的相簿中
    await GallerySaver.saveImage(imageFile.path, albumName: '登山 APP 相簿')
        .then((bool? saveSuccess) {
      saveSuccess ??= false;
      if (saveSuccess) {
        _markers.add(Marker(
            point: LatLng(currentLocation.latitude, currentLocation.longitude),
            builder: (context) => Transform.translate(
                  offset: const Offset(-5, -30),
                  child: const Icon(
                    Icons.photo,
                    size: 40,
                    color: Color.fromARGB(235, 255, 228, 92),
                  ),
                )));
        takePhotoDialog = MyAlertDialog(
            context: context,
            titleText: '照片儲存成功',
            contentText: '可以到手機的相簿中查看',
            btn1Text: '確認',
            btn2Text: '');
        takePhotoDialog.show();
        setState(() {});
      } else {
        takePhotoDialog = MyAlertDialog(
            context: context,
            titleText: '照片儲存失敗',
            contentText: '',
            btn1Text: '確認',
            btn2Text: '');
        takePhotoDialog.show();
      }
    });
  }
}
