import 'dart:io';
import 'dart:math';
import 'package:capstone_project/ui/track/fm_show_track_data.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_elevation/map_elevation.dart';

import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/map/user_location.dart';
import 'package:capstone_project/models/track/track_model.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:capstone_project/models/ui_model/input_dialog.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/gpx_service.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/services/kml_service.dart';
import 'package:capstone_project/services/sqlite_helper.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  File? gpxFile;
  String trackName = ''; // 使用者輸入的軌跡名稱

  final FileProvider fileProvider = FileProvider();
  late Directory? trackDir; // 軌跡資料夾
  late List? queryTrackList = []; // sqlite 軌跡資料表下的資料
  late List<LatLng> latLngList; // 抓軌跡檔案中的經緯度座標 List

  late MyAlertDialog noFileAlertDialog;
  late MyAlertDialog reChooseAlertDialog;
  late MyAlertDialog deleteTrackDialog;
  late MyAlertDialog deleteClientTrackFailDialog;
  late MyAlertDialog deleteServerTrackFailDialog;
  late MyAlertDialog insertClientTrackFailDialog;
  late MyAlertDialog insertServerTrackFailDialog;
  late MyAlertDialog uploadServerTrackFailDialog;
  late InputDialog nameFileDialog;

  @override
  void initState() {
    getAppTrackDirPath(); // 抓軌跡資料夾的檔案路徑
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 所有的 Widget Card
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      // decoration: const BoxDecoration(
      //     image: DecorationImage(
      //         image: defaultBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: lightGreen0,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkGreen1,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          title: const Center(
              child: Text(
            '軌跡列表',
          )),
          actions: [
            ElevatedButton(
              onPressed: () => _addTrackFile(context),
              // child: const Icon(Icons.camera_alt_outlined),
              child: const ImageIcon(insertIcon),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(30, 30),
                backgroundColor: transparentColor,
                shadowColor: transparentColor,
              ),
            ),
          ],
        ),
        body: showAllTrackFiles(),
      ),
    );
  }

  // 抓資料庫中軌跡的資料
  getTrackData() async {
    // 抓後端軌跡的資料
    var userID = {'uID': '${UserData.uid}'};
    List result = await APIService.selectUserAllTrack(userID);
    print('使用者 server 上所有軌跡的資料 $result');
    queryTrackList = await SqliteHelper.queryAll(tableName: 'track');
    queryTrackList ??= [];
    print(
        '=========\ncreate Track Check Table 1 $hasTrackCheckTable \n=========');
    // FIXME 檢查是否有漏下載的軌跡資料
    // if (result[0]) {
    //   checkLostTrackFile(
    //       serverTrackFiles: result[1], clientTrackFiles: queryTrackList);
    // }
    print('使用者 sqlite 上所有軌跡的資料 $queryTrackList');
    return queryTrackList;
  }

  // 檢查 tID 是否已在 trackDataList 中
  bool checkAddTID({required String tID, required List trackDataList}) {
    for (int i = 0; i < trackDataList.length; i++) {
      if (tID == trackDataList[i]['tID']) {
        return true;
      }
    }
    return false;
  }

  void createCheckTable(
      {required List serverTrackFiles, required List? clientTrackFiles}) {
    for (int i = 0; i < serverTrackFiles.length; i++) {
      bool hasAddTID = checkAddTID(
          tID: serverTrackFiles[i]['tID'].toString(),
          trackDataList: serverTrackData);
      if (!hasAddTID) {
        Map sTrackData = {
          'tID': serverTrackFiles[i]['tID'].toString(),
          'track_name': serverTrackFiles[i]['track_name'].toString(),
          'isDownloaded': false
        };
        serverTrackData.add(sTrackData);
      }
    }
  }

  void checkLostFile(
      {required List serverTrackData,
      required List serverTrackFiles,
      required List? clientTrackFiles}) async {
    if (clientTrackFiles!.isNotEmpty) {
      for (int s = 0; s < serverTrackData.length; s++) {
        for (int c = 0; c < clientTrackFiles.length; c++) {
          if (!serverTrackData[s]['isDownloaded']) {
            if (serverTrackData[s]['tID'] == clientTrackFiles[c]['tID']) {
              serverTrackData[s]['isDownloaded'] = true;
            } else {
              Map<String, dynamic> downloadTrackID = {
                'tID': serverTrackData[s]['tID']
              };
              String savePath =
                  '${trackDir!.path}/${serverTrackData[s]['track_name']}';
              // download server track file
              List downloadTrackResult = await APIService.downloadTrack(
                  savePath: savePath, content: downloadTrackID);
              if (downloadTrackResult[0]) {
                // insert sqlite track data
                Track newClientTrackData = Track(
                    tID: serverTrackFiles[s]['tID'],
                    uID: UserData.uid.toString(),
                    track_name: serverTrackFiles[s]['track_name'],
                    track_locate: serverTrackFiles[s]['track_locate'],
                    start: serverTrackFiles[s]['start'],
                    finish: serverTrackFiles[s]['finish'],
                    total_distance: serverTrackFiles[s]['total_distance'],
                    time: serverTrackFiles[s]['time'],
                    track_type: serverTrackFiles[s]['track_type']);
                List insertClientTrackResult = await SqliteHelper.insert(
                    tableName: 'track', insertData: newClientTrackData.toMap());
                if (insertClientTrackResult[0]) {
                  serverTrackData[s]['isDownloaded'] = true;
                  print('$s 本機端新增軌跡 ${serverTrackFiles[s]['tID']} 成功');
                } else {
                  print('$s 本機端新增軌跡 ${serverTrackFiles[s]['tID']} 失敗');
                }
              } else {
                print(downloadTrackResult[1]);
                print('$s server 下載軌跡 ${serverTrackFiles[s]['tID']} 失敗');
              }
            }
          }
        }
      }
    } else {
      print(' download all track files');
    }
  }

  //  檢查 server 和 client 端的軌跡資料是否同步
  void checkLostTrackFile(
      {required List serverTrackFiles, required List? clientTrackFiles}) {
    if (serverTrackFiles.isEmpty) {
      print('server 上沒資料');
      return;
    }
    if (!hasTrackCheckTable) {
      createCheckTable(
          serverTrackFiles: serverTrackFiles,
          clientTrackFiles: clientTrackFiles);
      hasTrackCheckTable = true;
    }
    checkLostFile(
        serverTrackData: serverTrackData,
        serverTrackFiles: serverTrackFiles,
        clientTrackFiles: clientTrackFiles);

    print('SERVER TRACK FILES $serverTrackData');
    // print('CLIENT TRACK FILES $clientTrackData');
    print(
        '=========\ncreate Track Check Table 2 $hasTrackCheckTable \n=========');
  }

  Future<void> getAppTrackDirPath() async {
    await fileProvider.getAppPath;
    trackDir = await fileProvider.getSpecificDir(dirName: 'trackData');
    print(
        'APP 軌跡資料夾下的所有檔案 ${await fileProvider.getDirFileList(specifiedDir: trackDir)}');
  }

  Future<void> _pushDelete(
      {required BuildContext context,
      required List<dynamic> deleteTrackData}) async {
    final File deleteFile = File(deleteTrackData[0]['track_locate']);
    deleteTrackDialog = MyAlertDialog(
        context: context,
        titleText: '刪除軌跡',
        contentText: '確定要刪除 ${deleteTrackData[0]['track_name']} ?',
        btn1Text: '刪除',
        btn2Text: '取消');
    bool? toDelete = await deleteTrackDialog.show();
    toDelete ??= false;

    if (toDelete) {
      var isDeleted = await fileProvider.deleteFile(file: deleteFile); // 刪除檔案
      if (isDeleted) {
        var deleteID = deleteTrackData[0]['tID'];
        Map<String, dynamic> deleteRequestModel = {
          'tID': deleteID,
          'uID': '${UserData.uid}'
        };
        // 刪除 server 軌跡檔案
        List deleteServerTrackResult =
            await APIService.deleteTrack(deleteRequestModel);
        if (deleteServerTrackResult[0]) {
          // 刪除 sqlite 軌跡資料
          var result = await SqliteHelper.delete(
              tableName: 'track',
              tableIdName: 'tID',
              deleteId: int.parse(deleteID));
          hasTrackCheckTable = false;
          setState(() {});
        } else {
          deleteServerTrackFailDialog = MyAlertDialog(
              context: context,
              titleText: 'server 刪除軌跡資料失敗',
              contentText: deleteServerTrackResult[1],
              btn1Text: '確認',
              btn2Text: '');
          deleteServerTrackFailDialog.show();
        }
      } else {
        deleteClientTrackFailDialog = MyAlertDialog(
            context: context,
            titleText: '刪除失敗',
            contentText: '找不到軌跡檔案',
            btn1Text: '確認',
            btn2Text: '');
        deleteClientTrackFailDialog.show();
      }
    } else {
      print('不要刪除軌跡');
      return;
    }
  }

  void _checkTrackData({
    required BuildContext context,
    required List<dynamic> trackData,
  }) async {
    File trackFile = File(trackData[0]['track_locate']);
    // 把 gpx 檔案轉成 string
    String result = await fileProvider.readFileAsString(file: trackFile);
    Map<String, dynamic> gpxResult = GPXService.getGPSList(content: result);
    List<LatLng> latLngList = gpxResult['latLngList']; // LatLng (沒有高度)
    List<ElevationPoint> elevationPointList =
        gpxResult['elevationPointList']; // ElevationPoint (有高度)
    LatLngBounds bounds = GPXService.getBounds(list: latLngList);
    LatLng centerLatLng = GPXService.getCenterLatLng(bounds: bounds);
    double zoomLevel = GPXService.getZoomLevel(
        bounds: bounds,
        mapDimensions: Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        ));

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShowTrackDataPage(
                trackData: trackData,
                trackFile: trackFile,
                latLngList: latLngList,
                elevationPointList: elevationPointList,
                bounds: bounds,
                centerLatLng: centerLatLng,
                zoomLevel: zoomLevel)));
  }

  // 匯入軌跡
  void _addTrackFile(BuildContext context) async {
    // 抓手機上任何類型的檔案
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null) {
      noFileAlertDialog = MyAlertDialog(
          context: context,
          titleText: '沒有選擇檔案匯入',
          contentText: '',
          btn1Text: '返回',
          btn2Text: '');
      noFileAlertDialog.show();
      return;
    }

    final PlatformFile file = result.files.single;
    final String? importFilePath = file.path;
    final fileType = file.extension; // 檔案類型
    late bool? toAdd;

    if (fileType != 'gpx' && fileType != 'kml') {
      reChooseAlertDialog = MyAlertDialog(
          context: context,
          titleText: '請重新選擇檔案',
          contentText: '你選擇的檔案類型不是 .gpx 或 .kml\n請重新選擇',
          btn1Text: '返回',
          btn2Text: '');
      reChooseAlertDialog.show();
      return;
    } else {
      nameFileDialog = InputDialog(
          context: context,
          myTitle: '新增軌跡資料',
          myContent: '幫你要匯入的軌跡取一個名字',
          defaultText: basenameWithoutExtension(file.name),
          inputFieldName: '軌跡名稱',
          btn1Text: '確認',
          btn2Text: '取消');
      List? result = await nameFileDialog.show();
      toAdd = result?[0];
      toAdd ??= false;
      if (toAdd) {
        trackName = '${result?[1]}.gpx';
      }
    }
    if (toAdd) {
      // late Track newTrackData;
      late File newTrackFile;
      // kml 轉 gpx
      if (fileType == 'kml' && importFilePath != null) {
        String result =
            await fileProvider.readFileAsString(file: File(importFilePath));
        List<UserLocation> userLocationList =
            KMLService.getGPSList(content: result);
        String gpxFile = GPXService.writeGPX(
            trackName: trackName,
            time: UserLocation.getCurrentTime(),
            userLocationList: userLocationList);
        String gpxFilePath = '${trackDir!.path}/$trackName';
        // 匯入 kml 檔案到 app 下
        newTrackFile = await fileProvider.writeFileAsString(
            content: gpxFile, path: gpxFilePath);
      } else {
        // 匯入 gpx 檔案到 app 下
        newTrackFile = await fileProvider.saveFile(
            file: file, fileName: trackName, dirPath: trackDir!.path);
      }
      // 要新增的軌跡資料
      // ===================
      String result = await fileProvider.readFileAsString(file: newTrackFile);
      Map<String, dynamic> gpxResult = GPXService.getGPSList(content: result);
      List<LatLng> latLngList = gpxResult['latLngList']; // LatLng (沒有高度)
      List<DateTime> timeList = gpxResult['timeList'];
      double distance = latLngListDistance(latLngList);
      DateTime startTime = DateTime.utc(0);
      DateTime finishTime = DateTime.utc(0);
      if (timeList.isNotEmpty) {
        startTime = timeList.first;
        finishTime = timeList.last;
      }
      // ===================
      final String currentDate =
          DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now());
      TrackRequestModel newServerTrackData = TrackRequestModel(
          uID: UserData.uid.toString(),
          track_name: fileProvider.getFileName(file: newTrackFile),
          track_locate: newTrackFile.path,
          start: DateFormat('yyyy-MM-dd hh:mm').format(startTime),
          finish: DateFormat('yyyy-MM-dd hh:mm').format(finishTime),
          total_distance: distance.toString(),
          time: currentDate,
          track_type: '0');
      print(newServerTrackData);

      List insertTrackResponse =
          await APIService.insertTrack(newServerTrackData);

      if (insertTrackResponse[0]) {
        String tID = insertTrackResponse[1]["tID"].toString();
        Map<String, String> trackID = {'tID': tID};
        List uploadTrackResponse =
            await APIService.uploadTrack(newTrackFile, trackID);
        print(uploadTrackResponse);
        if (uploadTrackResponse[0]) {
          Track newClientTrackData = Track(
              tID: tID,
              uID: UserData.uid.toString(),
              track_name: fileProvider.getFileName(file: newTrackFile),
              track_locate: newTrackFile.path,
              start: DateFormat('yyyy-MM-dd hh:mm').format(startTime),
              finish: DateFormat('yyyy-MM-dd hh:mm').format(finishTime),
              total_distance: distance.toString(),
              time: currentDate,
              track_type: '0');
          List insertClientTrackResult = await SqliteHelper.insert(
              tableName: 'track', insertData: newClientTrackData.toMap());
          if (!insertClientTrackResult[0]) {
            insertClientTrackFailDialog = MyAlertDialog(
                context: context,
                titleText: '本機端新增軌跡失敗',
                contentText: insertClientTrackResult[1].toString(),
                btn1Text: '確認',
                btn2Text: '');
            insertClientTrackFailDialog.show();
          } else {
            hasTrackCheckTable = false;
          }
        } else {
          uploadServerTrackFailDialog = MyAlertDialog(
              context: context,
              titleText: '上傳軌跡失敗',
              contentText: uploadTrackResponse[1].toString(),
              btn1Text: '確認',
              btn2Text: '');
          uploadServerTrackFailDialog.show();
        }
      } else {
        insertServerTrackFailDialog = MyAlertDialog(
            context: context,
            titleText: 'server 新增軌跡失敗',
            contentText: insertTrackResponse[1].toString(),
            btn1Text: '確認',
            btn2Text: '');
        insertServerTrackFailDialog.show();
      }
      setState(() {});
    }
    trackName = ''; // 把輸入的軌跡名稱清空
    return; // 如果沒有要匯入就 return
  }

  // 計算 LatLngList 的總距離
  double latLngListDistance(List<LatLng> latLngList) {
    double distance = 0;
    for (var i = 0; i < latLngList.length - 1; i++) {
      distance +=
          caculateDistance(point1: latLngList[i], point2: latLngList[i + 1]);
    }
    return distance;
  }

  // 計算三維空間的距離
  double caculateDistance({required LatLng point1, required LatLng point2}) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((point2.latitude - point1.latitude) * p) / 2 +
        cos(point1.latitude * p) *
            cos(point2.latitude * p) *
            (1 - cos((point2.longitude - point1.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  Widget showAllTrackFiles() {
    return FutureBuilder(
        future: getTrackData(),
        builder: (BuildContext context, AsyncSnapshot snap) {
          if (snap.hasData) {
            List list = snap.data;
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, idx) {
                return Column(
                  children: <Widget>[
                    Card(
                      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      color: transparentColor,
                      shadowColor: transparentColor,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            image: const DecorationImage(
                                fit: BoxFit.cover, image: trackListImage)),
                        child: ListTile(
                          title: Text(
                            list[idx]['track_name'],
                            style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              list[idx]['time'],
                              style: TextStyle(color: Colors.grey.shade300),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _pushDelete(
                                context: context, deleteTrackData: [list[idx]]),
                            color: Colors.white,
                            tooltip: '刪除軌跡',
                          ),
                          onTap: () => _checkTrackData(
                              context: context, trackData: [list[idx]]),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return Container();
        });
  }
}
