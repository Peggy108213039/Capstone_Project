import 'dart:io';
import 'package:capstone_project/models/ui_model/input_dialog.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:flutter_map/flutter_map.dart';

class ShowTrackDataPage extends StatefulWidget {
  const ShowTrackDataPage({Key? key}) : super(key: key);

  @override
  State<ShowTrackDataPage> createState() => _ShowTrackDataPageState();
}

class _ShowTrackDataPageState extends State<ShowTrackDataPage> {
  MapController? mapController;
  late FileProvider fileProvider;
  late InputDialog editTrackNameDialog; // 編輯軌跡名稱
  late ValueNotifier<String> _trackName;
  late String originalFileName;
  ElevationPoint? hoverPoint;

  @override
  void initState() {
    fileProvider = FileProvider();
    _trackName = ValueNotifier<String>('');
    super.initState();
  }

  @override
  void dispose() {
    mapController!.dispose();
    _trackName.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapController controller) async {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    print(
        'zoomLevel ${arguments['zoomLevel']} ,type ${arguments['zoomLevel'].runtimeType}');
    double width = MediaQuery.of(context).size.width;
    originalFileName = arguments['trackData'][0]['track_name'];
    _trackName.value = originalFileName;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          // 地圖上的軌跡
          Scaffold(
        appBar: AppBar(
          title: Center(
            child: ValueListenableBuilder(
                valueListenable: _trackName,
                builder: (context, value, child) => Text('$value')),
          ),
          backgroundColor: Colors.indigoAccent.shade100,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
            onPressed: () {
              Navigator.pushNamed(context, "/MyBottomBar1");
            },
            tooltip: '返回',
          ),
          actions: [
            IconButton(
              onPressed: () => editTrackName(
                  file: arguments['trackFile'],
                  context: context,
                  trackID: arguments['trackData'][0]['tID']),
              icon: const Icon(Icons.edit),
              tooltip: '編輯軌跡名稱',
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: width / 10 * 9,
                  height: width / 10 * 9,
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      onMapCreated: _onMapCreated,
                      center: arguments['centerLatLng'],
                      zoom: arguments['zoomLevel'],
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      PolylineLayerOptions(polylines: [
                        Polyline(
                          points: arguments['gpsList'],
                          color: Colors.green,
                          strokeWidth: 5,
                        )
                      ]),
                      MarkerLayerOptions(markers: [
                        if (hoverPoint is LatLng)
                          Marker(
                              point: hoverPoint!.latLng,
                              width: 8,
                              height: 8,
                              builder: ((BuildContext context) => Container(
                                    decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(8)),
                                  )))
                      ])
                    ],
                  ),
                ),
                // 軌跡相關資料
                TrackData(
                  width: width,
                  trackData: arguments['trackData'],
                ),
                // 軌跡高度表
                Container(
                    height: width / 10 * 5,
                    width: width / 10 * 9,
                    color: const Color.fromARGB(255, 200, 200, 200),
                    child: NotificationListener<ElevationHoverNotification>(
                        onNotification:
                            (ElevationHoverNotification notification) {
                          setState(() {
                            hoverPoint = notification.position;
                            print('hoverPoint');
                          });

                          return true;
                        },
                        child: Elevation(
                          arguments['elePoints'],
                          color: Colors.grey,
                          elevationGradientColors: ElevationGradientColors(
                              gt10: Colors.green,
                              gt20: Colors.orangeAccent,
                              gt30: Colors.redAccent),
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void editTrackName(
      {required File file,
      required BuildContext context,
      // required List<dynamic>? trackData,
      required int trackID}) async {
    print('========= _trackName.value ${_trackName.value} ==========');
    print('========= originalFileName $originalFileName ==========');
    print('trackID $trackID');
    // 跳出對話框，輸入要更改的名稱
    editTrackNameDialog = InputDialog(
        context: context,
        myTitle: '重新命名軌跡名稱',
        myContent: '',
        defaultText: originalFileName,
        inputFieldName: '軌跡名稱',
        btn1Text: '確認',
        btn2Text: '取消');
    List? result = await editTrackNameDialog.show();
    result?[0] ??= false; // 如果使用者點擊 '確認' 或 '取消' 按鈕以外的地方，也是回傳 false
    if (result?[0] == false || result?[0] == null) {
      return;
    }
    String newName = result?[1];
    print('newName $newName');
    // 沒有要重新命名
    if (result?[0] == false) {
      return;
    } else {
      // 檢查 新名稱 和 原本的名稱 一樣
      if (newName == originalFileName) {
        return;
      }
      _trackName.value = newName;
      originalFileName = newName;
      final sqliteResult = await SqliteHelper.queryRow(
          tableName: 'track', key: 'tID', value: trackID.toString());
      print('sqliteResult 0 $sqliteResult');
      File _file = File(sqliteResult?[0]['track_locate']);

      // 改檔名
      File newFile =
          await fileProvider.changeFileName(file: _file, newName: newName);
      Map<String, dynamic> updateData = {
        'track_name': newName,
        'track_locate': newFile.path
      };
      // 改 sqlite 檔案名稱
      await SqliteHelper.update(
          tableName: 'track',
          updateData: updateData,
          tableIdName: 'tID',
          updateID: trackID);
    }
    print('========= _trackName.value ${_trackName.value} ==========');
    print('========= originalFileName $originalFileName ==========');
    print('');
  }

  // 軌跡高度圖
  Widget trackElevation(
      {required double width,
      required List<ElevationPoint> elePoints,
      required ElevationPoint? hoverPoint}) {
    return Container(
        height: width / 10 * 5,
        width: width / 10 * 9,
        color: const Color.fromARGB(255, 200, 200, 200),
        child: NotificationListener<ElevationHoverNotification>(
            onNotification: (ElevationHoverNotification notification) {
              setState(() {
                hoverPoint = notification.position;
                print('hoverPoint');
              });

              return true;
            },
            child: Elevation(
              elePoints,
              color: Colors.grey,
              elevationGradientColors: ElevationGradientColors(
                  gt10: Colors.green,
                  gt20: Colors.orangeAccent,
                  gt30: Colors.redAccent),
            )));
  }
}

class TrackData extends StatefulWidget {
  final double width;
  final List<dynamic>? trackData; // 軌跡相關資料
  const TrackData({Key? key, required this.width, required this.trackData})
      : super(key: key);

  @override
  State<TrackData> createState() => _TrackDataState();
}

// 軌跡資料
class _TrackDataState extends State<TrackData> {
  final double wordSize1 = 23.0;
  final double wordSize2 = 18.0;
  String distanceUnit = '公里';
  String timeUnit = '小時';
  double distance = 0;
  String velocity = '0';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width;
    final trackData = widget.trackData; // 軌跡資料

    final totaltime = DateTime.parse(trackData?[0]['finish'])
        .difference(DateTime.parse(trackData?[0]['start']));
    final String durationTime = durationFormat(totaltime); // 步行總時間
    final int timeSecond = totaltime.inSeconds; // (秒)
    final double totalDistance =
        double.parse(trackData?[0]['total_distance']); // (公里)
    print('========== trackData $trackData ==========');
    if (timeSecond == 0) {
      velocity = 0.toString();
    } else {
      double _velocity = 0.0;
      // 如果總距離小於 1 公里，總距離單位轉成 1 公尺
      if (totalDistance < 1) {
        distance = (totalDistance * 1000); // 公尺
        distanceUnit = '公尺';
        timeUnit = '分鐘';
        // 公尺/分鐘
        _velocity = (distance / timeSecond * 60);
        print(' 公尺/分鐘 distance $distance timeSecond $timeSecond');
      } else {
        distance = totalDistance; // 公里
        // 公里/小時
        _velocity = (distance / timeSecond * 60 * 60);
        print(' 公里/小時 distance $distance timeSecond $timeSecond');
      }
      velocity = _velocity.toStringAsFixed(2);
    }

    return SizedBox(
      //   Container(
      // color: Colors.indigoAccent.shade100,
      width: width / 10 * 9,
      height: width / 5 * 1.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 主軸 (直) 的排版
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 主軸 (橫) 的排版
            children: [
              myCard(
                  width: width,
                  s1: '距離',
                  s2: distance.toString(),
                  s3: distanceUnit),
              myCard(width: width, s1: '步行時間', s2: durationTime, s3: '小時:分鐘'),
              myCard(
                  width: width,
                  s1: '速度',
                  s2: velocity,
                  s3: '$distanceUnit/$timeUnit'),
            ],
          ),
        ],
      ),
    );
  }

  Widget myCard(
      {required double width,
      required String s1,
      required String s2,
      required String s3}) {
    return Card(
      shadowColor: Colors.grey,
      color: Colors.amber.shade50,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: SizedBox(
        height: width / 10 * 2.3,
        width: width / 10 * 2.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              s1,
              style: TextStyle(color: Colors.grey, fontSize: wordSize2),
            ),
            Text(
              s2,
              style: TextStyle(
                  color: const Color.fromRGBO(39, 34, 34, 1),
                  fontSize: wordSize1),
            ),
            Text(
              s3,
              style: TextStyle(color: Colors.grey, fontSize: wordSize2),
            ),
          ],
        ),
      ),
    );
  }

// 把 Duration 轉換成 hh:mm
  String durationFormat(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHour = twoDigits(duration.inHours.remainder(60));
    String twoDigitMinute = twoDigits(duration.inMinutes.remainder(60));
    return "$twoDigitHour:$twoDigitMinute";
  }
}
