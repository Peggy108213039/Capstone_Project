import 'dart:io';
import 'dart:math';

import 'package:capstone_project/models/map/offline_map_model.dart';
import 'package:capstone_project/models/ui_model/input_dialog.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'package:dart_numerics/dart_numerics.dart' as numerics;

class DownloadOfflineMap extends StatefulWidget {
  const DownloadOfflineMap({Key? key}) : super(key: key);

  @override
  State<DownloadOfflineMap> createState() => _DownloadOfflineMapState();
}

class _DownloadOfflineMapState extends State<DownloadOfflineMap> {
  MapController? mapController;
  FileProvider fileProvider = FileProvider();
  double zoomLevel = 13;
  int minZoom = 10;
  int maxZoom = 18;

  bool downloadSuccess = false;
  String downloadMessage = '移動地圖選擇想要下載的範圍';
  bool isDownloading = false;
  double linearPercentage = 0;

  late InputDialog inputOfflineMapNameDialog; // 輸入軌跡名稱

  @override
  void initState() {
    // getAppTrackDirPath(); // 抓軌跡資料夾的檔案路徑

    super.initState();
  }

  @override
  void dispose() {
    print('===== 刪掉 dispose =====');
    mapController!.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapController controller) async {
    mapController = controller;
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('下載離線地圖')),
        backgroundColor: Colors.indigoAccent.shade100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: '返回',
          onPressed: () => Navigator.pushNamed(context, '/TestOfflineMap'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mySpace(10),
            SizedBox(
              width: width / 10 * 9.5,
              height: height / 10 * 6.5,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  onMapCreated: _onMapCreated,
                  center: LatLng(23.94981257, 120.92764976),
                  zoom: zoomLevel,
                  maxBounds: LatLngBounds(
                      LatLng(23.78634741851813, 120.75903619038363),
                      LatLng(24.114141889661123, 121.0876408564609)),
                  swPanBoundary: LatLng(23.78634741851813, 120.75903619038363),
                  nePanBoundary: LatLng(24.114141889661123, 121.0876408564609),
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                ],
              ),
            ),
            mySpace(30),
            ElevatedButton(
              child: const Text('下載'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade300),
              onPressed: () => pushDownloadBtn(context: context),
            ),
            mySpace(10),
            Text(
              downloadMessage,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            mySpace(10),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: LinearProgressIndicator(
                backgroundColor: Color.fromARGB(255, 184, 195, 253),
                color: Colors.indigoAccent,
                value: linearPercentage,
              ),
            )
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getMapData() {
    LatLng center = mapController!.center;
    LatLngBounds? bounds = mapController!.bounds;
    List tileBounds = [];
    for (var i = minZoom; i <= maxZoom; i++) {
      // SW NE
      Map<String, dynamic> swTile = deg2num(bounds!.southWest, i);
      Map<String, dynamic> neTile = deg2num(bounds.northEast, i);
      Map<String, dynamic> tileBound = {
        "swTile": swTile,
        "neTile": neTile,
        "zoom": i
      };
      tileBounds.add(tileBound);
    }
    return {"center": center, "bounds": bounds, "tileBounds": tileBounds};
  }

  Future<Directory?> createDirectory(String dirName) async {
    print('zoom dir name $dirName');
    return await fileProvider.getSpecificDir(dirName: dirName);
  }

  void downloadTiles(
      {required LatLng center,
      required LatLngBounds? bounds,
      required List tileBounds,
      required String offlineMapName}) async {
    isDownloading = true;
    // 下載每個 zoom 中所有的 tiles
    for (var i = 0; i < tileBounds.length; i++) {
      // 找出 minX、maxX
      List xList = [tileBounds[i]['swTile']['x'], tileBounds[i]['neTile']['x']];
      xList.sort();
      int minX = xList[0];
      int maxX = xList.last;
      // 找出 minY、maxY
      List yList = [tileBounds[i]['swTile']['y'], tileBounds[i]['neTile']['y']];
      yList.sort();
      int minY = yList[0];
      int maxY = yList.last;
      int z = tileBounds[i]['zoom'];
      for (var x = minX; x <= maxX; x++) {
        Directory? zoomDir =
            await createDirectory('offlineMap/$offlineMapName/$z/$x');
        // 下載每個座標為 x 的所有點
        for (var y = minY; y <= maxY; y++) {
          String urlPath =
              'http://163.22.17.247:3000/api/test/test_download?z=$z&x=$x&y=$y';
          String savePath = '${zoomDir!.path}/$y.png';
          print('savePath   $savePath');
          try {
            await Dio().download(urlPath, savePath,
                onReceiveProgress: (actualBytes, totalBytes) {
              if (totalBytes != -1) {
                var percentage = actualBytes / totalBytes * 100;
                linearPercentage = percentage / 100;
                setState(() {
                  downloadMessage =
                      'Downloading /$z/$x/$y.png ... ${percentage.floor()} %';
                });
                print(downloadMessage);
              }
            });
            print("Image is saved to download folder.");
            downloadSuccess = true;
          } on DioError catch (err) {
            print(err.message);
            downloadSuccess = false;
            setState(() {
              downloadMessage = '${err.message} \n下載 /$z/$x/$y.png ... 失敗';
            });
          }
        }
      }
    }
    if (downloadSuccess) {
      Directory? destinationDirPath = await fileProvider.getSpecificDir(
          dirName: 'offlineMap/$offlineMapName');
      if (destinationDirPath != null) {
        print('離線地圖檔案目錄 ${destinationDirPath.path}');
        var offlineMapPngDirPath = destinationDirPath.path;
        Map<String, dynamic> newOfflineMapData = OfflineMap(
                uID: '1',
                offline_map_name: offlineMapName,
                centerLatitude: center.latitude.toString(),
                centerLongitude: center.longitude.toString(),
                southWestLatitude: bounds!.southWest!.latitude.toString(),
                southWestLongitude: bounds.southWest!.longitude.toString(),
                northEastLatitude: bounds.northEast!.latitude.toString(),
                northEastLongitude: bounds.northEast!.longitude.toString(),
                png_dir_locate: offlineMapPngDirPath)
            .toMap();
        print('離線地圖資料 $newOfflineMapData');
        await SqliteHelper.insert(
            tableName: 'offlineMap', insertData: newOfflineMapData);
        print('離線地圖資料存入 Sqlite 成功');
        setState(() {
          downloadMessage = '離線地圖已下載完畢，可以到離線地圖頁面查看';
        });
      }
    } else {
      print('下載失敗');
      setState(() {
        downloadMessage = '下載失敗';
      });
    }
    isDownloading = false;
  }

  Map<String, dynamic> deg2num(LatLng? point, int zoom) {
    double latRadians = degreeToRadians(point!.latitude);
    num n = pow(2, zoom);
    int xTile = ((point.longitude + 180) / 360 * n).toInt();
    int yTile = ((1.0 - numerics.asinh(tan(latRadians)) / pi) / 2 * n).toInt();
    return {"x": xTile, "y": yTile};
  }

  double degreeToRadians(double degree) {
    return degree * pi / 180;
  }

  SizedBox mySpace(double num) {
    return SizedBox(height: num);
  }

  void pushDownloadBtn({required BuildContext context}) async {
    print('開始下載離線地圖');
    Map<String, dynamic> result = getMapData();
    print(result);
    inputOfflineMapNameDialog = InputDialog(
        context: context,
        myTitle: '新增離線地圖資料',
        myContent: '幫你的離線地圖取一個名字',
        defaultText: '離線地圖名稱',
        inputFieldName: '離線地圖名稱',
        btn1Text: '確認',
        btn2Text: '取消');
    List? dialogResult = await inputOfflineMapNameDialog.show();
    while (dialogResult?[0] != true && dialogResult?[0] != false) {
      dialogResult = await inputOfflineMapNameDialog.show();
    }
    // 確認儲存軌跡
    if (dialogResult?[0]) {
      String newName = dialogResult?[1] ?? 'test';
      if (isDownloading) {
        print('正在下載，請耐心等待');
      } else {
        downloadTiles(
            center: result['center'],
            bounds: result['bounds'],
            tileBounds: result['tileBounds'],
            offlineMapName: newName);
      }
    } else {
      print('不要儲存軌跡 result?[0] ${dialogResult?[0]}');
    }
  }
}
