import 'dart:io';

import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:capstone_project/models/ui_model/input_dialog.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class TestOfflineMap extends StatefulWidget {
  const TestOfflineMap({Key? key}) : super(key: key);

  @override
  State<TestOfflineMap> createState() => _TestOfflineMapState();
}

class _TestOfflineMapState extends State<TestOfflineMap> {
  String offlineMapName = ''; // 使用者輸入的離線地圖名稱

  final FileProvider fileProvider = FileProvider();
  late Directory? offlineMapDir; // 離線地圖資料夾
  late List? queryOfflineMapList = []; // 離線地圖資料表下的資料

  final ValueNotifier<bool> _visible = ValueNotifier<bool>(false);
  late MyAlertDialog noFileAlertDialog;
  late MyAlertDialog reChooseAlertDialog;
  late MyAlertDialog deleteOfflineMapDialog;
  late MyAlertDialog deleteFailDialog;
  late InputDialog nameFileDialog;

  @override
  void initState() {
    getOfflineMapsDirPath(); // 抓離線地圖資料夾的檔案路徑
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent.shade100,
        title: const Center(
          child: Text('離線地圖'),
        ),
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
            tooltip: '編輯離線地圖',
          )
        ],
      ),
      body: showAllOfflineMapFiles(),
      floatingActionButton: FloatingActionButton(
        tooltip: "下載離線地圖",
        onPressed: () {
          print('下載離線地圖');
          Navigator.pushNamed(context, '/DownloadOfflineMap');
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigoAccent.shade100,
        child: const Text('下載\n地圖'),
      ),
    );
  }

  Future<void> getOfflineMapsDirPath() async {
    // 抓此 APP 的檔案路徑
    await fileProvider.getAppPath;
    // 抓離線地圖資料夾
    offlineMapDir = await fileProvider.getSpecificDir(dirName: 'offlineMap');

    print('離線地圖資料夾路徑 ${offlineMapDir!.path}');
    // FIXME 檢查是否 1~18 縮放程度的地圖都有下載
    // List mapDir = await fileProvider.getDirFileList(
    //     specifiedDir: Directory('${offlineMapDir!.path}/NCNU/18/'));
    // print('FIXME 檢查是否 1~18 縮放程度的地圖都有下載');
    // for (int i = 0; i < mapDir.length; i++) {
    //   print(mapDir[i].path);
    // }
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

  // // 匯入離線地圖
  // void _addOfflineMap(BuildContext context) async {
  //   // 抓手機上任何類型的檔案
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //   );

  //   if (result == null) {
  //     noFileAlertDialog = MyAlertDialog(
  //         context: context,
  //         titleText: '沒有選擇檔案匯入',
  //         contentText: '',
  //         btn1Text: '返回',
  //         btn2Text: '');
  //     noFileAlertDialog.show();
  //     return;
  //   }

  //   final PlatformFile file = result.files.single;
  //   final String? importFilePath = file.path;
  //   final fileType = file.extension; // 檔案類型
  //   late bool? toAdd;

  //   // if (fileType != 'mbtiles') {
  //   if (fileType != 'zip') {
  //     reChooseAlertDialog = MyAlertDialog(
  //         context: context,
  //         titleText: '請重新選擇檔案',
  //         // contentText: '你選擇的檔案類型不是 .mbtiles\n請重新選擇',
  //         contentText: '你選擇的檔案類型不是 .zip\n請重新選擇',
  //         btn1Text: '返回',
  //         btn2Text: '');
  //     reChooseAlertDialog.show();
  //     return;
  //   } else {
  //     nameFileDialog = InputDialog(
  //         context: context,
  //         myTitle: '新增離線地圖',
  //         myContent: '幫你匯入的離線地圖取一個名字',
  //         defaultText: file.name,
  //         inputFieldName: '離線地圖名稱',
  //         btn1Text: '確認',
  //         btn2Text: '取消');
  //     List? result = await nameFileDialog.show();
  //     toAdd = result?[0];
  //     toAdd ??= false;
  //     if (toAdd) {
  //       offlineMapName = result?[1];
  //     }
  //   }
  //   if (toAdd) {
  //     late Map<String, dynamic> newOfflineMapData;
  //     late File zipFile;

  //     // destinationDirPath 匯入離線地圖的儲存位置
  //     Directory? destinationDirPath = await fileProvider.getSpecificDir(
  //         dirName: 'offlineMap/$offlineMapName');
  //     print('離線地圖檔案目錄 ${destinationDirPath!.path}');

  //     // ======= mbtile file =======
  //     // 匯入 離線地圖 檔案
  //     // File importFile = await fileProvider.saveFile(
  //     //     file: file,
  //     //     fileName: offlineMapName,
  //     //     dirPath: destinationDirPath.path);
  //     // print('離線地圖壓縮檔的目錄   ${importFile.path}');

  //     // MbtilesService mbtilesService = MbtilesService();
  //     // List<Map<String, dynamic>>? metadata =
  //     //     await mbtilesService.queryMetadata(mbtilesFilePath: file.path);
  //     // List<Map<String, dynamic>>? tiles =
  //     //     await mbtilesService.queryTiles(mbtilesFilePath: file.path);
  //     // Directory offlineMapPngDir = await mbtilesService.downloadAllTileGraph(
  //     //     tilesData: tiles,
  //     //     dirName: 'offlineMap/$offlineMapName/$offlineMapName');
  //     // mbtilesService.closeDB();
  //     // ======= mbtile file =======

  //     // ======= zip File =======
  //     // 匯入 離線地圖 檔案
  //     zipFile = await fileProvider.saveFile(
  //         file: file,
  //         fileName: offlineMapName,
  //         dirPath: destinationDirPath.path);
  //     print('離線地圖壓縮檔的目錄   ${zipFile.parent}');

  //     List<dynamic> result = await fileProvider.extractZipFile(
  //         destinationDirPath: destinationDirPath.path,
  //         zipFilePath: zipFile.path);

  //     print('解壓縮檔 $result');

  //     // ======= zip File =======
  //     if (result[0] != 'Extract ZIP fail') {
  //       String offlineMapPngDirPath = result[1].path;
  //       newOfflineMapData = OfflineMap(
  //               uID: '1',
  //               offline_map_name: offlineMapName,
  //               png_dir_locate: offlineMapPngDirPath)
  //           .toMap();
  //       print('離線地圖資料 $newOfflineMapData');
  //       await SqliteHelper.insert(
  //           tableName: 'offlineMap', insertData: newOfflineMapData);

  //       offlineMapName = ''; // 把輸入的離線地圖名稱清空
  //       setState(() {});
  //     } else {
  //       print('解壓縮失敗');
  //     }
  //   }
  //   return; // 如果沒有要匯入就 return
  // }

  Widget showAllOfflineMapFiles() {
    print('show All Offline Map Files');
    return FutureBuilder(
        future: getOfflineMaps(),
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
                        list[idx]['offline_map_name'],
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: ValueListenableBuilder(
                        valueListenable: _visible,
                        builder: (context, value, child) => Visibility(
                          visible: _visible.value,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _pushDelete(
                                context: context,
                                deleteOfflienMap: [list[idx]]),
                            color: Colors.grey.shade400,
                            tooltip: '刪除離線地圖',
                          ),
                        ),
                      ),
                      onTap: () => _checkOfflineMap(
                          context: context,
                          offlineMapData: [list[idx]],
                          offlineMapPath: list[idx]['png_dir_locate']),
                    ),
                    const Divider(
                      height: 10.0,
                    ),
                  ],
                );
              },
            );
          }
          return const Text('沒有離線地圖的檔案');
        });
  }

  // 抓資料庫中離線地圖的資料
  getOfflineMaps() async {
    queryOfflineMapList = await SqliteHelper.queryAll(tableName: 'offlineMap');
    print('DB QUERY offlineMap DATA $queryOfflineMapList');
    return queryOfflineMapList;
  }

  Future<void> _pushDelete(
      {required BuildContext context,
      required List<dynamic> deleteOfflienMap}) async {
    print('deleteOfflienMap $deleteOfflienMap');
    final Directory deleteDirectory =
        Directory(deleteOfflienMap[0]['png_dir_locate']);
    print('deleteDirectory $deleteDirectory');
    deleteOfflineMapDialog = MyAlertDialog(
        context: context,
        titleText: '刪除離線地圖',
        contentText: '確定要刪除 ${deleteOfflienMap[0]['offline_map_name']} ?',
        btn1Text: '刪除',
        btn2Text: '取消');
    bool? toDelete = await deleteOfflineMapDialog.show();
    toDelete ??= false;

    print('是否要刪除離線地圖 $toDelete');
    if (toDelete) {
      var isDeleted = await fileProvider.deleteDirectory(
          directory: deleteDirectory); // 刪除檔案
      if (isDeleted) {
        // 已經刪完檔案
        var deleteID = deleteOfflienMap[0]['offline_map_ID'];
        var result = await SqliteHelper.delete(
            tableName: 'offlineMap',
            tableIdName: 'offline_map_ID',
            deleteId: deleteID);
        print('sqlite 刪除結果 $result');
        setState(() {});
      } else {
        deleteFailDialog = MyAlertDialog(
            context: context,
            titleText: '刪除離線地圖失敗',
            contentText: '找不到檔案',
            btn1Text: '確認',
            btn2Text: '');
        deleteFailDialog.show();
      }
    } else {
      print('不要刪除離線地圖');
      return;
    }
  }

  void _checkOfflineMap(
      {required BuildContext context,
      required List offlineMapData,
      required String offlineMapPath}) async {
    Navigator.pushNamed(context, "/OfflineMapPage", arguments: {
      'offlineMapData': offlineMapData,
      'offlineMapPath': offlineMapPath,
    });
    // Navigator.pushNamed(context, '/TestShowOfflineMapPage');
  }
}
