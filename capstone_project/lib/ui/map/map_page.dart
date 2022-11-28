import 'dart:io';
import 'dart:async';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/models/track/track_model.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:capstone_project/models/ui_model/input_dialog.dart';
import 'package:capstone_project/models/ui_model/warning_time.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/gpx_service.dart';
import 'package:capstone_project/services/location_service.dart';
import 'package:capstone_project/services/polyline_coordinates_model.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/ui/map/show_flutter_map.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late Directory? trackDir; // 軌跡資料夾
  final FileProvider fileProvider = FileProvider();
  List<Marker> markers = []; // 標記拍照點

  late MyAlertDialog pauseDialog; // 提醒視窗：暫停紀錄
  late MyAlertDialog dataNotEnoughDialog; // 提醒視窗：軌跡資料不足，無法紀錄
  late MyAlertDialog saveFileSuccessDialog; // 提醒視窗：軌跡檔案儲存成功
  late InputDialog inputTrackNameDialog; // 輸入軌跡名稱
  late MyAlertDialog takePhotoDialog; // 提醒視窗：照片儲存成功

  // button style
  final raisedBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(50, 50),
      shape: const CircleBorder(),
      backgroundColor: darkGreen1);
  final startBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(60, 60),
      shape: const CircleBorder(),
      foregroundColor: Colors.amber,
      backgroundColor: Colors.white);
  final stopBtnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(60, 60),
      shape: const CircleBorder(),
      foregroundColor: Colors.redAccent,
      backgroundColor: Colors.white);

  @override
  void initState() {
    getTrackDirPath();
    super.initState();
  }

  @override
  void dispose() {
    print('===== 刪掉 dispose =====');
    // LocationService.closeService();
    mapIsStarted = false;
    mapIsPaused = false;
    mapPolyline.clearList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('===== 建立地圖頁面 =====');

    if (!mapIsStarted && !mapIsPaused) {
      markers.clear();
    }

    // 去抓使用者手機螢幕的高
    double height = MediaQuery.of(context).size.height;

    SizedBox mySpace(double num) {
      return SizedBox(height: (height * num));
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Center(child: Text('地圖頁面')),
          backgroundColor: darkGreen1,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
        ),
        body: Stack(children: [
          ShowFlutterMap(
              isStarted: mapIsStarted,
              isPaused: mapIsPaused,
              polyline: mapPolyline,
              markerList: markers),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WarningTime(
                isStarted: mapIsStarted,
                isPaused: mapIsPaused,
                checkTime: 10, // FIXME
                warningTime: 180, // FIXME
              ),
            ],
          ),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => takePhoto(markers),
                      child: const ImageIcon(
                        cameraIcon,
                        size: 35,
                      ),
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
                      child: mapIsStarted
                          ? const ImageIcon(
                              endIcon,
                              size: 33,
                            )
                          : const ImageIcon(
                              startIcon,
                              size: 40.0,
                            ),
                      style: mapIsStarted ? stopBtnStyle : startBtnStyle,
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
    if (!mapIsStarted && !mapIsPaused) {
      setState(() {
        mapIsStarted = !mapIsStarted;
      });
      return;
    }
    // 開始後，按暫停 (開始)
    if (mapIsStarted && !mapIsPaused) {
      mapIsPaused = true;
    }
    // 暫停後，確認要繼續或停止紀錄 (暫停)
    if (mapIsStarted && mapIsPaused) {
      pauseDialog = MyAlertDialog(
          context: context,
          titleText: '暫停紀錄軌跡',
          titleFontSize: 30,
          contentText: '',
          contentFontSize: 20,
          btn1Text: '繼續記錄', // true
          btn2Text: '結束紀錄'); // false
      bool? result = await pauseDialog.show();
      while (result != true && result != false) {
        result = await pauseDialog.show();
      }

      mapIsStarted = result!;
      // 如果是停止紀錄
      if (!mapIsStarted && mapIsPaused) {
        if (mapPolyline.userLocationList.length < 2) {
          dataNotEnoughDialog = MyAlertDialog(
              context: context,
              titleText: '移動距離太短，無法紀錄',
              titleFontSize: 30,
              contentText: '',
              contentFontSize: 20,
              btn1Text: '確認',
              btn2Text: '');
          await dataNotEnoughDialog.show();
          mapPolyline.clearList(); // 清空 polyline list
          // 切換成開始狀態
          setState(() {
            mapIsStarted = false;
            mapIsPaused = false;
          });
          return;
        }
        // 跳出對話框，讓使用者輸入軌跡名稱
        inputTrackNameDialog = InputDialog(
            context: context,
            myTitle: '新增軌跡資料',
            myTitleFontSize: 30,
            myContent: '幫你的軌跡取一個名字',
            myContentFontSize: 20,
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
              userLocationList: mapPolyline.userLocationList);
          String newFilePath = '${trackDir!.path}/$newName.gpx';
          File newTrackFile = await fileProvider.writeFileAsString(
              content: gpxFile, path: newFilePath);
          bool writeSuccess =
              await fileProvider.fileIsExists(file: File(newFilePath));
          if (writeSuccess) {
            TrackRequestModel newServerTrackData = TrackRequestModel(
                uID: UserData.uid.toString(),
                track_name: newName,
                track_locate: newFilePath,
                start: mapPolyline.userLocationList[0].currentTime,
                finish: mapPolyline.userLocationList.last.currentTime,
                total_distance: mapPolyline.totalDistance.toStringAsFixed(3),
                time: UserLocation.getCurrentTime(),
                track_type: '1');
            List insertTrackResponse =
                await APIService.insertTrack(newServerTrackData);
            if (insertTrackResponse[0]) {
              String tID = insertTrackResponse[1]["tID"].toString();
              Map<String, String> trackID = {'tID': tID};
              List uploadTrackResponse =
                  await APIService.uploadTrack(newTrackFile, trackID);
              if (uploadTrackResponse[0]) {
                final Track newTrackData = Track(
                    tID: tID,
                    uID: UserData.uid.toString(),
                    track_name: newName,
                    track_locate: newFilePath,
                    start: mapPolyline.userLocationList[0].currentTime,
                    finish: mapPolyline.userLocationList.last.currentTime,
                    total_distance:
                        mapPolyline.totalDistance.toStringAsFixed(3),
                    time: UserLocation.getCurrentTime(),
                    track_type: '1');
                List insertClientTrackResult = await SqliteHelper.insert(
                    tableName: 'track', insertData: newTrackData.toMap());
                // server 更新使用者累積距離、時間
                final totaltime = DateTime.parse(
                        mapPolyline.userLocationList.last.currentTime)
                    .difference(DateTime.parse(
                        mapPolyline.userLocationList[0].currentTime));
                Map<String, String> updateMemberDistanceTimeRequest = {
                  'uID': UserData.uid.toString(),
                  'total_distance':
                      (mapPolyline.totalDistance * 1000).round().toString(),
                  'total_time': totaltime.inMinutes.toString()
                };
                await APIService.updateDistanceTimeMember(
                    content: updateMemberDistanceTimeRequest);
                // server 更新使用者累積軌跡數量
                await APIService.updateTrackMember(
                    content: {'uID': UserData.uid.toString()});
                if (insertClientTrackResult[0]) {
                  saveFileSuccessDialog = MyAlertDialog(
                      context: context,
                      titleText: '檔案儲存成功',
                      titleFontSize: 30,
                      contentText: '可以到軌跡頁面查看檔案',
                      contentFontSize: 20,
                      btn1Text: '確認',
                      btn2Text: '');
                  await saveFileSuccessDialog.show();
                  setState(() {
                    mapIsPaused = false;
                    mapIsStarted = false;
                  });
                  mapPolyline.clearList(); // 清空 polyline list
                  return;
                } else {
                  print('sqlite 新增軌跡資料失敗 ${insertClientTrackResult[1]}');
                }
              } else {
                print('server 上傳軌跡資料失敗 ${uploadTrackResponse[1]}');
              }
            } else {
              print('server 插入軌跡資料失敗 ${insertTrackResponse[1]}');
            }
          } else {
            print('寫入失敗 writeSuccess $writeSuccess');
          }
        } else {
          print('不要儲存軌跡 result?[0] ${result?[0]}');
        }
        // server 更新使用者累積距離、時間
        final totaltime = DateTime.parse(
                mapPolyline.userLocationList.last.currentTime)
            .difference(
                DateTime.parse(mapPolyline.userLocationList[0].currentTime));
        Map<String, String> updateMemberDistanceTimeRequest = {
          'uID': UserData.uid.toString(),
          'total_distance':
              (mapPolyline.totalDistance * 1000).round().toString(),
          'total_time': totaltime.inMinutes.toString()
        };
        await APIService.updateDistanceTimeMember(
            content: updateMemberDistanceTimeRequest);
        mapPolyline.clearList(); // 清空 polyline list
      } // 如果要繼續記錄
      // 切換成開始狀態
      mapIsPaused = false;
    }
    setState(() {});
  }

  void takePhoto(List<Marker> markers) async {
    File? imageFile;
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    if (pickedFile == null) {
      return;
    }
    imageFile = File(pickedFile.path);
    // 存到手機的相簿中
    bool? saveSuccess =
        await GallerySaver.saveImage(imageFile.path, albumName: '與山同行');
    saveSuccess ??= false;
    UserLocation? photoLocation = userLocation;

    if (saveSuccess) {
      markers.add(Marker(
          point: photoLocation.toLatLng(),
          builder: (context) => Transform.translate(
                offset: const Offset(-5, -30),
                child: const Icon(
                  Icons.photo,
                  size: 40,
                  color: Color.fromARGB(235, 254, 47, 1),
                ),
              )));
      takePhotoDialog = MyAlertDialog(
          context: context,
          titleText: '照片儲存成功',
          titleFontSize: 30,
          contentText: '可以到手機的相簿中查看',
          contentFontSize: 20,
          btn1Text: '確認',
          btn2Text: '');
      await takePhotoDialog.show();
    } else {
      takePhotoDialog = MyAlertDialog(
          context: context,
          titleText: '照片儲存失敗',
          titleFontSize: 30,
          contentText: '',
          contentFontSize: 20,
          btn1Text: '確認',
          btn2Text: '');
      await takePhotoDialog.show();
    }
  }
}
