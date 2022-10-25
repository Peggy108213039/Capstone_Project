import 'dart:io';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/gpx_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:capstone_project/services/sqlite_helper.dart';

class ShowActivityData extends StatefulWidget {
  const ShowActivityData({Key? key}) : super(key: key);

  @override
  State<ShowActivityData> createState() => _ShowActivityDataState();
}

class _ShowActivityDataState extends State<ShowActivityData> {
  FileProvider fileProvider = FileProvider();
  late List<LatLng> gpsList;

  @override
  Widget build(BuildContext context) {
    // 去抓使用者手機螢幕的長、寬
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    print(arguments);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent.shade100,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () {
            Navigator.pushNamed(context, "/MyBottomBar3");
          },
          tooltip: '返回',
        ),
        title: const Center(child: Text('活動資料')),
        actions: [
          IconButton(
              onPressed: () {
                // FIXME 編輯活動資料
                print('編輯活動資料 $arguments');
                Navigator.pushNamed(context, '/EditActivityData',
                    arguments: arguments);
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.fromLTRB(15, 20, 15, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildText(
                  content: '活動名稱 : ${arguments['activity_name']}',
                  fontSize: 20,
                  subText: '',
                  subTextSize: 0,
                  width: width),
              buildText(
                  content: '活動時間 : ${arguments['activity_time']}',
                  fontSize: 20,
                  subText: '',
                  subTextSize: 0,
                  width: width),
              showTrack(tID: arguments['tID'], width: width),
              // FIXME 同行成員
              buildText(
                  content: '同行成員 :',
                  fontSize: 20,
                  subText: '',
                  subTextSize: 0,
                  width: width),
              buildText(
                  content: '最遠距離 : ${arguments['warning_distance']} 公尺',
                  fontSize: 20,
                  subText: '補充說明 : 同行成員中，第一位成員與最後一位成員的距離不得超過此距離',
                  subTextSize: 12,
                  width: width),
              buildText(
                  content: '停留時間 : ${arguments['warning_time']} 分鐘',
                  fontSize: 20,
                  subText: '補充說明 : 同行成員中，任何一位成員停留於原地時間不得超過此時間',
                  subTextSize: 12,
                  width: width),
              mySpace(30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text('開始活動'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade300),
                    // FIXME 開始活動按鈕
                    onPressed: () {
                      print('開始活動');
                      Navigator.pushNamed(context, '/StartActivity',
                          arguments: {
                            'activity_name': arguments['activity_name'],
                            'activity_time': arguments['activity_time'],
                            'gpsList': gpsList,
                            'warning_distance': arguments['warning_distance'],
                            'warning_time': arguments['warning_time'],
                          });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildText(
      {required String content,
      required double fontSize,
      required String subText,
      required double subTextSize,
      required double width}) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: TextStyle(fontSize: fontSize),
            ),
            if (subText != '' && subTextSize != 0) mySpace(6),
            SizedBox(
              width: width - 30,
              child: Text(
                subText,
                softWrap: true,
                style: TextStyle(color: Colors.grey, fontSize: subTextSize),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                height: 3,
                width: width - 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: const Color.fromARGB(255, 213, 213, 213)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  SizedBox mySpace(double num) {
    return SizedBox(height: num);
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
          print('bounds ${bounds.northEast} ${bounds.southWest}');
          print('zoomLevel $zoomLevel');

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '活動軌跡 : ${trackData['track_name']}',
                style: const TextStyle(fontSize: 20),
              ),
              mySpace(6),
              SizedBox(
                width: width / 10 * 9,
                height: width / 10 * 9,
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
                    ),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  height: 3,
                  width: width - 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: const Color.fromARGB(255, 213, 213, 213)),
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
    print('tID $tID ${tID.runtimeType}');
    List<Map<String, dynamic>>? trackData =
        await SqliteHelper.queryRow(tableName: 'track', key: 'tID', value: tID);
    print('track data  $trackData');
    if (trackData!.isEmpty) {
      print('\nNO DATA\n');
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
