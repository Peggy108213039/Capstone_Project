import 'dart:io';
import 'package:capstone_project/services/cache_tile_provider.dart';
import 'package:capstone_project/ui/track/track_data.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_elevation/map_elevation.dart';

import 'package:capstone_project/models/ui_model/input_dialog.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/sqlite_helper.dart';

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
                  trackID: int.parse(arguments['trackData'][0]['tID'])),
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
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
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
                          tileProvider: CachedTileProvider()),
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
                                        color: const Color.fromARGB(
                                            255, 255, 7, 7),
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
                    margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    color: const Color.fromARGB(255, 200, 200, 200),
                    child: Stack(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 20, 5, 20),
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
                              color: Colors.green.shade100,
                              elevationGradientColors: ElevationGradientColors(
                                  // gradient 坡度
                                  gt10: Colors.green,
                                  gt20: Colors.orangeAccent,
                                  gt30: Colors.redAccent),
                            )),
                      ),
                      const Positioned(left: 6, top: 3, child: Text('高度')),
                      // const Positioned(right: 0, bottom: 0, child: Text('時間'))
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
  }
}
