import 'dart:io';
import 'package:capstone_project/constants.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_elevation/map_elevation.dart';

import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/ui/track/track_data.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/services/cache_tile_provider.dart';
import 'package:capstone_project/models/ui_model/input_dialog.dart';

class ShowTrackDataPage extends StatefulWidget {
  final List<dynamic> trackData;
  final File trackFile;
  final List<LatLng> latLngList;
  final List<ElevationPoint> elevationPointList;
  final LatLngBounds bounds;
  final LatLng centerLatLng;
  final double zoomLevel;
  const ShowTrackDataPage(
      {Key? key,
      required this.trackData,
      required this.trackFile,
      required this.latLngList,
      required this.elevationPointList,
      required this.bounds,
      required this.centerLatLng,
      required this.zoomLevel})
      : super(key: key);

  @override
  State<ShowTrackDataPage> createState() => _ShowTrackDataPageState();
}

class _ShowTrackDataPageState extends State<ShowTrackDataPage> {
  MapController? mapController;
  late FileProvider fileProvider;

  final ValueNotifier<String> _trackName = ValueNotifier<String>('');
  late String originalFileName;
  ElevationPoint? hoverPoint;

  late InputDialog editTrackNameDialog; // 編輯軌跡名稱

  late List<dynamic> trackData;
  late File trackFile;
  late List<LatLng> latLngList;
  late List<ElevationPoint> elevationPointList;
  late LatLngBounds bounds;
  late LatLng centerLatLng;
  late double zoomLevel;

  @override
  void initState() {
    trackData = widget.trackData;
    trackFile = widget.trackFile;
    latLngList = widget.latLngList;
    elevationPointList = widget.elevationPointList;
    bounds = widget.bounds;
    centerLatLng = widget.centerLatLng;
    zoomLevel = widget.zoomLevel;

    fileProvider = FileProvider();
    originalFileName = basenameWithoutExtension(trackData[0]['track_locate']);
    _trackName.value = originalFileName;
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
    double width = MediaQuery.of(context).size.width;

    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: defaultBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: transparentColor,
        appBar: AppBar(
          title: Center(
            child: ValueListenableBuilder(
                valueListenable: _trackName,
                builder: (context, value, child) => Text('$value')),
          ),
          backgroundColor: darkGreen1,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          leading: ElevatedButton(
            child: const ImageIcon(backIcon),
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(30, 30),
                backgroundColor: transparentColor,
                shadowColor: transparentColor),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => editTrackName(
                  file: trackFile,
                  context: context,
                  trackID: int.parse(trackData[0]['tID'])),
              child: const ImageIcon(editIcon),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(30, 30),
                  backgroundColor: transparentColor,
                  shadowColor: transparentColor),
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
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                  decoration: BoxDecoration(
                    border: Border.all(width: 3, color: darkGreen1),
                    // borderRadius: BorderRadius.circular(30)
                  ),
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      onMapCreated: _onMapCreated,
                      center: centerLatLng,
                      zoom: zoomLevel,
                    ),
                    layers: [
                      TileLayerOptions(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c'],
                          tileProvider: CachedTileProvider()),
                      PolylineLayerOptions(polylines: [
                        Polyline(
                          points: latLngList,
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
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 1.5, color: Colors.white)),
                                  )))
                      ])
                    ],
                  ),
                ),
                // 軌跡相關資料
                TrackData(
                  width: width,
                  trackData: trackData,
                ),
                // 軌跡高度表
                Container(
                    height: width / 10 * 5,
                    width: width / 10 * 9,
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    color: const Color.fromARGB(150, 78, 135, 140),
                    child: Stack(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 20, 5, 20),
                        child: NotificationListener<ElevationHoverNotification>(
                            onNotification:
                                (ElevationHoverNotification notification) {
                              setState(() {
                                hoverPoint = notification.position;
                                // print('hoverPoint');
                              });

                              return true;
                            },
                            child: Elevation(
                              elevationPointList,
                              color: Colors.green.shade100,
                              // elevationGradientColors: ElevationGradientColors(
                              //     // gradient 坡度
                              //     gt10: Colors.green,
                              //     gt20: Colors.orangeAccent,
                              //     gt30: Colors.redAccent),
                            )),
                      ),
                      const Positioned(
                          left: 6,
                          top: 3,
                          child: Text(
                            '高度',
                            style: TextStyle(color: lightGreen0),
                          )),
                      const Positioned(
                          right: 3,
                          bottom: 6,
                          child:
                              Text('距離', style: TextStyle(color: lightGreen0)))
                    ]))
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
    // 跳出對話框，輸入要更改的名稱
    editTrackNameDialog = InputDialog(
        context: context,
        myTitle: '重新命名軌跡名稱',
        myTitleFontSize: 30,
        myContent: '',
        myContentFontSize: 20,
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
      File _file = File(sqliteResult?[0]['track_locate']);

      // 改檔名
      File newFile =
          await fileProvider.changeFileName(file: _file, newName: newName);
      Map<String, dynamic> updateData = {
        'track_name': newName,
        'track_locate': newFile.path
      };

      // 改 server 檔案名稱
      Map<String, dynamic> updateTrackRequest = {
        'uID': UserData.uid.toString(),
        'tID': trackID.toString(),
        'track_name': newName.toString()
      };
      List response =
          await APIService.updateTrackName(content: updateTrackRequest);
      print('response $response');

      // 改 sqlite 檔案名稱
      await SqliteHelper.update(
          tableName: 'track',
          updateData: updateData,
          tableIdName: 'tID',
          updateID: trackID);
    }
  }
}
