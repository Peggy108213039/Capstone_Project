import 'dart:io';

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
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:intl/intl.dart';

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
  final ValueNotifier<bool> _visible = ValueNotifier<bool>(false);
  late MyAlertDialog noFileAlertDialog;
  late MyAlertDialog reChooseAlertDialog;
  late MyAlertDialog deleteTrackDialog;
  late MyAlertDialog deleteTrackFailDialog;
  late MyAlertDialog insertTrackFailDialog;
  late MyAlertDialog uploadTrackFailDialog;
  late InputDialog nameFileDialog;

  @override
  void initState() {
    getAppTrackDirPath(); // 抓軌跡資料夾的檔案路徑

    super.initState();
  }

  @override
  void dispose() {
    _visible.dispose();
    super.dispose();
  }

  // 所有的 Widget Card
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: defaultBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: transparentColor,
        appBar: AppBar(
          backgroundColor: transparentColor,
          title: const Center(
              child: Text(
            '軌跡列表',
          )),
          leading: ValueListenableBuilder(
            valueListenable: _visible,
            builder: (context, value, child) => Visibility(
              visible: _visible.value,
              child: IconButton(
                onPressed: _pushBack,
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: '返回',
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: _pushDeleteBtn,
              icon: const Icon(Icons.delete_outline_rounded),
              iconSize: 30,
              tooltip: '編輯軌跡',
            )
          ],
        ),
        body: showAllTrackFiles(),
        floatingActionButton: FloatingActionButton(
          tooltip: "新增軌跡",
          onPressed: () => _addTrackFile(context),
          foregroundColor: Colors.white,
          backgroundColor: Colors.indigoAccent.shade100,
          child: const Icon(
            Icons.add,
            size: 35.0,
          ),
        ),
      ),
    );
  }

  // 抓資料庫中軌跡的資料
  getTrackData() async {
    // FIXME 抓後端軌跡的資料
    // var userID = {'uID': '9'}; // FIXME 要換成 sqlite 中 user 的資料
    // bool result = await APIService.selectUserAllTrack(userID);
    // print('使用者所有軌跡的資料 $result');
    queryTrackList = await SqliteHelper.queryAll(tableName: 'track');
    return queryTrackList;
  }

  Future<void> getAppTrackDirPath() async {
    await fileProvider.getAppPath;
    trackDir = await fileProvider.getSpecificDir(dirName: 'trackData');
  }

  void _pushBack() {
    _visible.value = false;
  }

  void _pushDeleteBtn() {
    // FIXME：除了刪除和返回，其他按鈕不能按
    showDeleteBtn();
  }

  void showDeleteBtn() {
    _visible.value = true;
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
        // FIXME 刪除 server 軌跡檔案
        // 已經刪完檔案
        var deleteID = deleteTrackData[0]['tID'];
        // 刪除 sqlite 軌跡資料
        var result = await SqliteHelper.delete(
            tableName: 'track', tableIdName: 'tID', deleteId: deleteID);
        print('sqlite 刪除結果 $result');
        setState(() {});
      } else {
        deleteTrackFailDialog = MyAlertDialog(
            context: context,
            titleText: '刪除失敗',
            contentText: '找不到檔案',
            btn1Text: '確認',
            btn2Text: '');
        deleteTrackFailDialog.show();
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

    Navigator.pushNamed(context, "/ShowTrackDataPage", arguments: {
      'trackData': trackData,
      'trackFile': trackFile,
      'gpsList': latLngList,
      'elePoints': elevationPointList,
      'bounds': bounds,
      'centerLatLng': centerLatLng,
      'zoomLevel': zoomLevel,
    });
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
          defaultText: file.name,
          inputFieldName: '軌跡名稱',
          btn1Text: '確認',
          btn2Text: '取消');
      List? result = await nameFileDialog.show();
      toAdd = result?[0];
      toAdd ??= false;
      if (toAdd) {
        trackName = result?[1];
      }
    }
    if (toAdd) {
      late Track newTrackData;
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
        String gpxFilePath = '${trackDir!.path}/$trackName.gpx';
        // 匯入 kml 檔案到 app 下
        newTrackFile = await fileProvider.writeFileAsString(
            content: gpxFile, path: gpxFilePath);
      } else {
        // 匯入 gpx 檔案到 app 下
        newTrackFile = await fileProvider.saveFile(
            file: file, fileName: trackName, dirPath: trackDir!.path);
      }
      // 要新增的軌跡資料
      final String currentDate =
          DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now());
      newTrackData = Track(
          uID: '9', // FIXME uID
          track_name: fileProvider.getFileName(file: newTrackFile),
          track_locate: newTrackFile.path,
          start: DateFormat('yyyy-MM-dd hh:mm').format(DateTime.utc(0)),
          finish: DateFormat('yyyy-MM-dd hh:mm').format(DateTime.utc(0)),
          total_distance: '0',
          time: currentDate,
          track_type: '0');
      print(newTrackData);

      List insertTrackResponse = await APIService.insertTrack(newTrackData);

      if (insertTrackResponse[0]) {
        print('ID ${insertTrackResponse[1]['tID']}');
        String tID = insertTrackResponse[1]["tID"].toString();
        Map<String, String> trackID = {
          'tID': tID,
          'filename': newTrackData.track_name
        };
        List uploadTrackResponse =
            await APIService.uploadTrack(newTrackFile, trackID);
        print(uploadTrackResponse);
        if (uploadTrackResponse[0]) {
          await SqliteHelper.insert(
              tableName: 'track', insertData: newTrackData.toMap());
        } else {
          uploadTrackFailDialog = MyAlertDialog(
              context: context,
              titleText: '上傳軌跡失敗',
              contentText: uploadTrackResponse[1].toString(),
              btn1Text: '確認',
              btn2Text: '');
          uploadTrackFailDialog.show();
        }
      } else {
        insertTrackFailDialog = MyAlertDialog(
            context: context,
            titleText: '新增軌跡失敗',
            contentText: insertTrackResponse[1].toString(),
            btn1Text: '確認',
            btn2Text: '');
        insertTrackFailDialog.show();
      }
      setState(() {});
    }
    trackName = ''; // 把輸入的軌跡名稱清空
    return; // 如果沒有要匯入就 return
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
                    ListTile(
                      title: Text(
                        list[idx]['track_name'],
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          list[idx]['time'],
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ),
                      trailing: ValueListenableBuilder(
                        valueListenable: _visible,
                        builder: (context, value, child) => Visibility(
                          visible: _visible.value,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _pushDelete(
                                context: context, deleteTrackData: [list[idx]]),
                            color: Colors.grey.shade400,
                            tooltip: '刪除軌跡',
                          ),
                        ),
                      ),
                      onTap: () => _checkTrackData(
                          context: context, trackData: [list[idx]]),
                    ),
                    const Divider(
                      height: 10.0,
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
