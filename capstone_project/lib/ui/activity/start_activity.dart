import 'dart:convert';
import 'dart:io';
import 'package:capstone_project/services/notification_service.dart';
import 'package:capstone_project/ui/activity/warning_member_too_long_text.dart';
import 'package:intl/intl.dart';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/track/track_model.dart';
import 'package:capstone_project/models/ui_model/warning_time.dart';
import 'package:capstone_project/services/audio_player.dart';
import 'package:capstone_project/services/gpx_service.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/services/polyline_coordinates_model.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/services/stream_socket.dart';
import 'package:capstone_project/ui/activity/activity_map_widget.dart';
import 'package:capstone_project/ui/activity/warning_distance_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:capstone_project/models/ui_model/input_dialog.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/location_service.dart';
import 'package:provider/provider.dart';

class StartActivity extends StatefulWidget {
  final List<LatLng> gpsList;
  // final List members;
  const StartActivity({Key? key, required this.gpsList
      // , required this.members
      })
      : super(key: key);

  @override
  State<StartActivity> createState() => _StartActivityState();
}

class _StartActivityState extends State<StartActivity> {
  late Directory? trackDir; // 軌跡資料夾
  final FileProvider fileProvider = FileProvider();
  late List<LatLng> gpsList;
  // List frindsIDList = [];
  List<Polyline> memberPolylines = [];
  // List<Marker> memberMarkers = [];

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
    gpsList = widget.gpsList;
    getTrackDirPath();
    super.initState();
  }

  @override
  void dispose() {
    print('===== 刪掉 dispose =====');
    clearPolylineList();
    activPolyline.clearList();
    activityFrindsIDList.clear();
    activirtMemberMarkers.clear();
    activityIsStarted = false;
    activityIsPaused = false;
    userStoppedInActivity = false;
    memberMarkersUpdate = false;
    activityMsg = '';
    activityMemberStopTooLongText = '';
    showActivityMemberStopTooLongText.value = false;
    super.dispose();
  }

  void clearPolylineList() {
    activityPolyLineList.clear();
  }

  @override
  Widget build(BuildContext context) {
    print('===== 建立活動地圖頁面 START =====');
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    activitySharePosition = arguments['shareUserPosition'];

    if (!activityIsStarted && !activityIsPaused) {
      markers.clear();
    }

    // 抓使用者手機螢幕的高
    double height = MediaQuery.of(context).size.height;
    print(
        'showActivityMemberStopTooLongText $showActivityMemberStopTooLongText');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('活動開始')),
          backgroundColor: darkGreen1,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
        ),
        body: Stack(children: [
          ActivityMap(
            gpsList: gpsList,
            isStarted: activityIsStarted,
            isPaused: activityIsPaused,
            markerList: markers,
            // activityMsg: '${arguments['aID']} ${arguments['activity_name']}',
            // memberMarkers: activirtMemberMarkers,
            // memberPolylines: memberPolylines,
            warningDistance: double.parse(arguments['warning_distance']),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(
              children: [
                WarningTime(
                  isStarted: activityIsStarted,
                  isPaused: activityIsPaused,
                  checkTime: 10,
                  warningTime: int.parse(arguments['warning_time']) * 60,
                  // checkTime: 10, // FIXME: For test
                  // warningTime: 180, // FIXME: For test
                  isActivity: true,
                ),
                WarningDistanceText(
                  isStarted: activityIsStarted,
                  isPaused: activityIsPaused,
                  gpsList: gpsList,
                  activWarnDistance:
                      double.parse(arguments['warning_distance']),
                  trackWarningDistance: 20,
                ),
                WarningMemberTooLongText(
                  isStarted: activityIsStarted,
                  isPaused: activityIsPaused,
                ),
              ],
            ),
          ]),
        ]),
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
                      takePhoto(
                          markers: markers,
                          activName: arguments['activity_name'].toString());
                    },
                    child: const Icon(Icons.camera_alt_outlined),
                    style: raisedBtnStyle,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/AR',
                          arguments: {'gpsList': gpsList});
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
            mySpace(height: height, num: 0.06),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    pushRecordBtn(
                        context: context,
                        aID: arguments['aID'].toString(),
                        uID: arguments['uID'].toString());
                  },
                  child: activityIsStarted
                      ? const ImageIcon(
                          endIcon,
                          size: 33,
                        )
                      : const ImageIcon(
                          startIcon,
                          size: 40.0,
                        ),
                  style: activityIsStarted ? stopBtnStyle : startBtnStyle,
                ),
              ],
            ),
            mySpace(height: height, num: 0.025),
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

  void pushRecordBtn(
      {required BuildContext context,
      required String aID,
      required String uID}) async {
    print('紀錄按鈕   aID $aID    uID $uID');
    // 剛開始 (預設值)
    if (!activityIsStarted && !activityIsPaused) {
      setState(() {
        activityIsStarted = !activityIsStarted;
      });
      return;
    }
    // 開始後，按暫停 (開始)
    if (activityIsStarted && !activityIsPaused) {
      activityIsPaused = true;
    }
    // 暫停後，確認要繼續或停止紀錄 (暫停)
    if (activityIsStarted && activityIsPaused) {
      pauseDialog = MyAlertDialog(
          context: context,
          titleText: '暫停紀錄軌跡',
          titleFontSize: 30,
          contentText: '',
          contentFontSize: 20,
          btn1Text: '繼續記錄', // true
          btn2Text: '結束紀錄'); // falsepushRecordBtn
      bool? result = await pauseDialog.show();
      while (result != true && result != false) {
        result = await pauseDialog.show();
      }

      activityIsStarted = result!;
      // 如果是停止紀錄
      if (!activityIsStarted && activityIsPaused) {
        if (activPolyline.userLocationList.length < 2) {
          dataNotEnoughDialog = MyAlertDialog(
              context: context,
              titleText: '移動距離太短，無法紀錄',
              titleFontSize: 30,
              contentText: '',
              contentFontSize: 20,
              btn1Text: '確認',
              btn2Text: '');
          await dataNotEnoughDialog.show();
          activPolyline.clearList(); // 清空 polyline list
          // 切換成開始狀態
          setState(() {
            activityIsStarted = false;
            activityIsPaused = false;
          });
          return;
        }
        if (UserData.uid.toString() == uID) {
          print('結束 server 活動');
          final finishActivityReq = {'aID': aID};
          List finishActivityResponse =
              await APIService.finishActivity(content: finishActivityReq);
          if (finishActivityResponse[0]) {
            print('結束活動 成功');
            print(finishActivityResponse[1]);
            String sqliteStartActivityTime =
                DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
            Map<String, dynamic> updateActivityStartTime = {
              'start_activity_time': sqliteStartActivityTime
            };
            await SqliteHelper.update(
                tableName: 'activity',
                updateData: updateActivityStartTime,
                tableIdName: 'aID',
                updateID: int.parse(aID));
          } else {
            print('結束活動 失敗');
            print(finishActivityResponse[1]);
          }
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
        while (result?[0] != true && result?[0] != false) {
          result = await inputTrackNameDialog.show();
        }
        // 確認儲存軌跡
        if (result?[0]) {
          String newName = result?[1];
          String gpxFile = GPXService.writeGPX(
              trackName: newName,
              time: UserLocation.getCurrentTime(),
              userLocationList: activPolyline.userLocationList);
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
                start: activPolyline.userLocationList[0].currentTime,
                finish: activPolyline.userLocationList.last.currentTime,
                total_distance: activPolyline.totalDistance.toStringAsFixed(3),
                time: UserLocation.getCurrentTime(),
                track_type: '2');
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
                  start: activPolyline.userLocationList[0].currentTime,
                  finish: activPolyline.userLocationList.last.currentTime,
                  total_distance:
                      activPolyline.totalDistance.toStringAsFixed(3),
                  time: UserLocation.getCurrentTime(),
                  track_type: '2',
                );
                List insertClientTrackResult = await SqliteHelper.insert(
                    tableName: 'track', insertData: newTrackData.toMap());
                // server 更新使用者累積距離、時間
                final totaltime = DateTime.parse(
                        activPolyline.userLocationList.last.currentTime)
                    .difference(DateTime.parse(
                        activPolyline.userLocationList[0].currentTime));
                Map<String, String> updateMemberDistanceTimeRequest = {
                  'uID': UserData.uid.toString(),
                  'total_distance':
                      (activPolyline.totalDistance * 1000).round().toString(),
                  'total_time': totaltime.inMinutes.toString()
                };
                await APIService.updateDistanceTimeMember(
                    content: updateMemberDistanceTimeRequest);
                // server 更新使用者累積軌跡數量
                await APIService.updateTrackMember(
                    content: {'uID': UserData.uid.toString()});
                // server 更新使用者累積活動數量
                await APIService.updateActivityMember(
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
                    activityIsPaused = false;
                    activityIsStarted = false;
                  });
                  activPolyline.clearList(); // 清空 polyline list
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
                activPolyline.userLocationList.last.currentTime)
            .difference(
                DateTime.parse(activPolyline.userLocationList[0].currentTime));
        Map<String, String> updateMemberDistanceTimeRequest = {
          'uID': UserData.uid.toString(),
          'total_distance':
              (activPolyline.totalDistance * 1000).round().toString(),
          'total_time': totaltime.inMinutes.toString()
        };
        await APIService.updateDistanceTimeMember(
            content: updateMemberDistanceTimeRequest);
        // server 更新使用者累積活動數量
        await APIService.updateActivityMember(
            content: {'uID': UserData.uid.toString()});
        activPolyline.clearList(); // 清空 polyline list
      } // 如果要繼續記錄
      // 切換成開始狀態
      activityIsPaused = false;
    }
    setState(() {});
  }

  void takePhoto(
      {required List<Marker> markers, required String activName}) async {
    File? imageFile;
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    if (pickedFile == null) {
      return;
    }
    imageFile = File(pickedFile.path);
    // 存到手機的相簿中
    bool? saveSuccess = await GallerySaver.saveImage(imageFile.path,
        albumName: '與山同行_$activName');
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
