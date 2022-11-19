import 'dart:io';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:capstone_project/services/cache_tile_provider.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/ui/activity/start_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import 'package:capstone_project/services/gpx_service.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/sqlite_helper.dart';

class ShowActivityData extends StatefulWidget {
  const ShowActivityData({Key? key}) : super(key: key);

  @override
  State<ShowActivityData> createState() => _ShowActivityDataState();
}

class _ShowActivityDataState extends State<ShowActivityData> {
  FileProvider fileProvider = FileProvider();
  late List<LatLng> gpsList;

  late List? queryFriendTable = [];
  late List<String> frindsIDList;
  List friendList = [];
  String memberString = '';

  // bool? sharePostion = false;
  late MyAlertDialog sharePositionDialog; // 提醒視窗：問同行者是否要分享位置
  ValueNotifier<bool> isVisible = ValueNotifier<bool>(false); // 是否顯示開始活動的按鈕

  @override
  void initState() {
    getSqliteData();
    super.initState();
  }

  @override
  void dispose() {
    isVisible.dispose();
    super.dispose();
  }

  void getSqliteData() async {
    queryFriendTable = await SqliteHelper.queryAll(tableName: 'friend');
    queryFriendTable ??= [];
    setState(() {
      queryFriendTable;
    });
  }

  void getMemberList(List frindsIDList) {
    memberString = '';
    friendList.clear();
    for (var member in queryFriendTable!) {
      if (frindsIDList.contains(member['uID'].toString())) {
        friendList.add(member);
        memberString += (member['name'].toString() + '  ');
      }
    }
    if (memberString.isEmpty) {
      memberString = "無";
    }
  }

  @override
  Widget build(BuildContext context) {
    // 去抓使用者手機螢幕的長、寬
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    frindsIDList = arguments['activityData']['members'].toString().split(', ');
    getMemberList(frindsIDList);

    // FIXME 顯示 主辦人有 開始按鈕
    if (arguments['activityData']['uID'] == UserData.uid.toString()) {
      isVisible.value = true;
    } else if (arguments['activityData']['finish_activity_time'] != 'null') {
      isVisible.value = false;
    } else {
      if (arguments['activityData']['start_activity_time'] == 'null') {
        isVisible.value = false;
      } else {
        isVisible.value = true;
      }
    }
    print('${arguments['activityData']}');
    print('isVisible   ${isVisible.value}');

    // if (arguments['activityData']['sta'])
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGreen1,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))),
        automaticallyImplyLeading: false,
        title: const Center(child: Text('活動資料')),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/EditActivityData',
                  arguments: arguments['activityData']);
            },
            child: const ImageIcon(
              editIcon,
              size: 33,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(30, 30),
              backgroundColor: transparentColor,
              shadowColor: transparentColor,
            ),
          )
        ],
      ),
      backgroundColor: activityGreen,
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.fromLTRB(15, 20, 15, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildText(
                title: '活動主辦人',
                content: '${arguments['activityHostData']['name']}',
                fontSize: 20,
                subText: '',
                subTextSize: 0,
                width: width,
              ),
              buildText(
                  title: '活動名稱',
                  content:
                      '活動名稱 : ${arguments['activityData']['activity_name']}',
                  fontSize: 20,
                  subText: '',
                  subTextSize: 0,
                  width: width),
              buildText(
                  title: '活動時間',
                  content: '${arguments['activityData']['activity_time']}',
                  fontSize: 20,
                  subText: '',
                  subTextSize: 0,
                  width: width),
              showTrack(tID: arguments['activityData']['tID'], width: width),
              buildText(
                  title: '同行成員',
                  content: memberString,
                  fontSize: 20,
                  subText: '',
                  subTextSize: 0,
                  width: width),
              buildText(
                  title: '最遠距離',
                  content:
                      '${arguments['activityData']['warning_distance']} 公尺',
                  fontSize: 20,
                  subText: '補充說明 : 同行成員中，第一位成員與最後一位成員的距離不得超過此距離',
                  subTextSize: 12,
                  width: width),
              buildText(
                  title: '停留時間',
                  content: '${arguments['activityData']['warning_time']} 分鐘',
                  fontSize: 20,
                  subText: '補充說明 : 同行成員中，任何一位成員停留於原地時間不得超過此時間',
                  subTextSize: 12,
                  width: width),
              mySpace(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: isVisible,
                    builder: (context, bool value, child) => Visibility(
                      visible: value,
                      child: ElevatedButton(
                        child: const Text(
                          '開始活動',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(90, 50),
                            foregroundColor: darkGreen2,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        onPressed: () =>
                            pushStartActivityBtn(arguments: arguments),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pushStartActivityBtn(
      {required Map<dynamic, dynamic> arguments}) async {
    if (arguments['activityData']['uID'] == UserData.uid.toString()) {
      print('TRUE 是活動創辦人');
      final startActivityReq = {
        'aID': arguments['activityData']['aID'].toString()
      };
      List startActivityResponse =
          await APIService.startActivity(content: startActivityReq);
      if (startActivityResponse[0]) {
        print('開始活動成功');
        String sqliteStartActivityTime =
            DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
        Map<String, dynamic> updateActivityStartTime = {
          'start_activity_time': sqliteStartActivityTime
        };
        await SqliteHelper.update(
            tableName: 'activity',
            updateData: updateActivityStartTime,
            tableIdName: 'aID',
            updateID: int.parse(arguments['activityData']['aID']));
      } else {
        print('開始活動失敗');
        print('失敗 ${startActivityResponse[1]}');
      }
    } else {
      print('FALSE 不是活動創辦人');
    }
    bool? shareUserPosition = await sharePosition();
    Navigator.pushNamed(context, '/StartActivity', arguments: {
      'aID': arguments['activityData']['aID'],
      'activity_name': arguments['activityData']['activity_name'],
      'activity_time': arguments['activityData']['activity_time'],
      'gpsList': gpsList,
      'warning_distance': arguments['activityData']['warning_distance'],
      'warning_time': arguments['activityData']['warning_time'],
      'members': friendList,
      'shareUserPosition': shareUserPosition,
    });
  }

  String adjustStringLength({required String str}) {
    String _content = '';
    if (str.length > 33) {
      List<String> contentList = str.split('  ');
      String tempString = '';
      for (var element in contentList) {
        _content += (element + '  ');
        tempString += (element + '  ');
        if ((tempString + element).length > 33) {
          _content += '\n                   ';
          tempString = '';
        }
      }
    } else {
      _content = str;
    }
    return _content;
  }

  Widget buildText(
      {required String title,
      required String content,
      required double fontSize,
      required String subText,
      required double subTextSize,
      required double width}) {
    String _content = adjustStringLength(str: content);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: fontSize,
                    color: darkGreen2,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                padding: const EdgeInsets.fromLTRB(8, 5, 5, 5),
                width: width - 30,
                decoration: BoxDecoration(
                    color: grassGreen,
                    border: Border.all(width: 3, color: grassGreen),
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  _content,
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                ),
              ),
              if (subText != '' && subTextSize != 0) mySpace(6),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox mySpace(double num) {
    return SizedBox(height: num);
  }

  Future<bool?> sharePosition() async {
    sharePositionDialog = MyAlertDialog(
        context: context,
        titleText: '是否要分享位置給同行者？',
        contentText: '分享後，同行者可以看到你的軌跡\n若沒分享，同行者看不到你的軌跡',
        btn1Text: '要分享',
        btn2Text: '不要分享');
    bool? result = await sharePositionDialog.show();
    while (result != true && result != false) {
      result = await sharePositionDialog.show();
    }
    print('sharePostion  $result');
    return result;
  }

  Widget showTrack({required String tID, required double width}) {
    return FutureBuilder(
      future: getTrackData(tID: tID),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data['result'] == 'have track data') {
          var trackData = snapshot.data['trackData'][0];
          gpsList = snapshot.data['gpsList'];
          LatLngBounds bounds = snapshot.data['bounds'];
          var centerLatLng = snapshot.data['centerLatLng'];
          var zoomLevel = snapshot.data['zoomLevel'];

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '活動軌跡',
                style: TextStyle(
                    fontSize: 20,
                    color: darkGreen2,
                    fontWeight: FontWeight.w500),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                padding: const EdgeInsets.fromLTRB(8, 5, 5, 5),
                width: width - 30,
                decoration: BoxDecoration(
                    color: grassGreen,
                    border: Border.all(width: 3, color: grassGreen),
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  '${trackData['track_name']}',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              mySpace(6),
              Container(
                width: width / 10 * 9,
                height: width / 10 * 9,
                decoration: BoxDecoration(
                  border: Border.all(width: 3, color: grassGreen),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    center: centerLatLng,
                    zoom: zoomLevel,
                    swPanBoundary: bounds.southWest,
                    nePanBoundary: bounds.northEast,
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                        tileProvider: CachedTileProvider()),
                    PolylineLayerOptions(polylines: [
                      Polyline(
                        points: gpsList,
                        color: Colors.green,
                        strokeWidth: 5,
                      )
                    ])
                  ],
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('沒有活動軌跡'));
        }
      },
    );
  }

  Future<Map<String, dynamic>?> getTrackData({required String tID}) async {
    List<Map<String, dynamic>>? trackData =
        await SqliteHelper.queryRow(tableName: 'track', key: 'tID', value: tID);

    if (trackData!.isEmpty) {
      return {'result': 'no track data'};
    } else {
      File trackFile = File(trackData[0]['track_locate']);
      // 把 gpx 檔案轉成 string
      String result = await fileProvider.readFileAsString(file: trackFile);
      Map<String, dynamic> gpxResult = GPXService.getGPSList(content: result);
      // latLngList (gpsList)
      List<LatLng> latLngList = gpxResult['latLngList']; // LatLng (沒有高度)
      LatLngBounds bounds = GPXService.getBounds(list: latLngList);
      // centerLatLng
      LatLng centerLatLng = GPXService.getCenterLatLng(bounds: bounds);
      // zoomLevel
      double zoomLevel = GPXService.getZoomLevel(
          bounds: bounds,
          mapDimensions: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height,
          ));
      return {
        'result': 'have track data',
        'trackData': trackData,
        'gpsList': latLngList,
        'bounds': bounds,
        'centerLatLng': centerLatLng,
        'zoomLevel': zoomLevel
      };
    }
  }
}
