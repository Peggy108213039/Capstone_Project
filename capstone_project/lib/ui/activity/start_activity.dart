import 'dart:convert';
import 'dart:io';
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
import 'package:capstone_project/ui/activity/socket_warning_distance.dart';
import 'package:capstone_project/ui/activity/socket_warning_time.dart';
import 'package:capstone_project/ui/activity/warning_distance_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:capstone_project/models/ui_model/input_dialog.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/location_service.dart';
import 'package:provider/provider.dart';

class StartActivity extends StatefulWidget {
  final List<LatLng> gpsList;
  final List members;
  const StartActivity({Key? key, required this.gpsList, required this.members})
      : super(key: key);

  @override
  State<StartActivity> createState() => _StartActivityState();
}

class _StartActivityState extends State<StartActivity> {
  late Directory? trackDir; // 軌跡資料夾
  final FileProvider fileProvider = FileProvider();
  late List<LatLng> gpsList;
  late List frindsIDList;

  bool isStarted = false;
  bool isPaused = false;
  bool shareUserPosition = false;

  List<Marker> markers = []; // 標記拍照點

  late MyAlertDialog pauseDialog; // 提醒視窗：暫停紀錄
  late MyAlertDialog dataNotEnoughDialog; // 提醒視窗：軌跡資料不足，無法紀錄
  late MyAlertDialog saveFileSuccessDialog; // 提醒視窗：軌跡檔案儲存成功
  late InputDialog inputTrackNameDialog; // 輸入軌跡名稱
  late MyAlertDialog takePhotoDialog; // 提醒視窗：照片儲存成功

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
    gpsList = widget.gpsList;
    frindsIDList = widget.members;
    buildFriendPolyLine(frindsIDList: frindsIDList);
    getTrackDirPath();
    super.initState();
  }

  void buildFriendPolyLine({required List frindsIDList}) {
    if (frindsIDList.isNotEmpty) {
      for (int i = 0; i < frindsIDList.length; i++) {
        String memberName = frindsIDList[i]['account'].toString();
        PolylineCoordinates tempPolyline = PolylineCoordinates();
        activityPolyLineList
            .add({"account": memberName, "polyline": tempPolyline});
      }
    }
    print('activityPolyLineList $activityPolyLineList');
  }

  @override
  void dispose() {
    print('===== 刪掉 dispose =====');
    LocationService.closeService();
    clearPolylineList();
    super.dispose();
  }

  void clearPolylineList() {
    activityPolyLineList.clear();
  }

  void socketSituation({required Object? socketData}) {
    final tmpSocketData = jsonDecode(jsonEncode(socketData!));
    print('socketData $tmpSocketData  type ${tmpSocketData.runtimeType}');
    if (tmpSocketData.runtimeType != String) {
      final String ctlMsg = tmpSocketData['ctlmsg'];
      if (ctlMsg == "broadcast location") {
        // FIXME client 收到同行者的軌跡
        for (int i = 0; i < activityPolyLineList.length; i++) {
          if (tmpSocketData['account_msg'] ==
              activityPolyLineList[i]['account']) {
            activityPolyLineList[i]['polyline'].recordCoordinates(UserLocation(
                latitude: tmpSocketData['location_msg']['latitude'],
                longitude: tmpSocketData['location_msg']['longitude'],
                altitude: tmpSocketData['location_msg']['elevation'],
                currentTime: UserLocation.getCurrentTime()));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('===== 建立活動地圖頁面 START =====');
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    shareUserPosition = arguments['shareUserPosition'];

    // get Socket response
    final testSocketData = Provider.of<Object?>(context);
    socketSituation(socketData: testSocketData);

    // if (isStarted && !isPaused) {
    //   if (shareUserPosition) {
    //     // FIXME 將自己的軌跡送給 server
    //     // 放到 activity_map_widget
    //     StreamSocket.uploadUserLocation(
    //         activityMsg: activityMsg, location: userLocation);
    //   }
    // }

    if (!isStarted && !isPaused) {
      markers.clear();
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
        body: Stack(children: [
          ActivityMap(
            gpsList: gpsList,
            isStarted: isStarted,
            isPaused: isPaused,
            markerList: markers,
            sharePosition: shareUserPosition,
            activityMsg: '${arguments['aID']} ${arguments['activity_name']}',
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Column(
              children: [
                WarningTime(
                  isStarted: isStarted,
                  isPaused: isPaused,
                  checkTime: 2,
                  warningTime: int.parse(arguments['warning_time']) * 60,
                  // warningTime: 10,
                ),
                WarningDistanceText(
                  isStarted: isStarted,
                  isPaused: isPaused,
                  gpsList: gpsList,
                  warningDistance: double.parse(arguments['warning_distance']),
                ),
                SocketWarningDistance(
                    isStarted: isStarted,
                    isPaused: isPaused,
                    socketMssege: testSocketData),
                SocketWarningTime(
                    isStarted: isStarted,
                    isPaused: isPaused,
                    socketMssege: testSocketData)
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
            mySpace(height: height, num: 0.01),
            mySpace(height: height, num: 0.035),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    pushRecordBtn(
                        context: context, aID: arguments['aID'].toString());
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

  void pushRecordBtn(
      {required BuildContext context, required String aID}) async {
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
        // 結束活動
        final finishActivityReq = {'aID': aID};
        List finishActivityResponse =
            await APIService.finishActivity(content: finishActivityReq);
        if (finishActivityResponse[0]) {
          print('結束活動 成功');
          print(finishActivityResponse[1]);
        } else {
          print('結束活動 失敗');
          print(finishActivityResponse[1]);
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
          contentText: '可以到手機的相簿中查看',
          btn1Text: '確認',
          btn2Text: '');
      await takePhotoDialog.show();
    } else {
      takePhotoDialog = MyAlertDialog(
          context: context,
          titleText: '照片儲存失敗',
          contentText: '',
          btn1Text: '確認',
          btn2Text: '');
      await takePhotoDialog.show();
    }
  }
}
