import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_archive/flutter_archive.dart'; // (解) 壓縮檔案

class FileProvider {
  static Directory? thisAppStorage;
  List fileList = [];

  // 抓到此 APP 的檔案路徑 (使用者看得到，使用者操作而產生的檔案)
  Future<Directory?> get getAppPath async {
    thisAppStorage ??= await getApplicationDocumentsDirectory();
    return thisAppStorage;
  }

  // 在此 APP 路徑下建立一個 "dirName" 的資料夾
  Future<Directory?> getSpecificDir({required String dirName}) async {
    thisAppStorage ??= await getAppPath;
    Directory dir = Directory('${thisAppStorage?.path}/$dirName');
    print('Dir Path  ${dir.path}');
    var isExists = await dir.exists();
    if (!isExists) {
      dir = await dir.create(recursive: true);
    }
    return dir;
  }

  // 抓 specifiedDir 資料夾下的所有檔案
  Future<List> getDirFileList({required Directory? specifiedDir}) async {
    fileList = specifiedDir!.listSync(recursive: false, followLinks: false);
    return fileList;
  }

  // 存 file 到 資料夾下
  // 把匯入的檔案複製一份到指定的資料夾，回傳複製檔案的路徑
  Future<File> saveFile(
      {required PlatformFile file,
      required String fileName,
      required String dirPath}) async {
    final File newFile;
    if (fileName != '') {
      newFile = File('$dirPath/$fileName');
    } else {
      newFile = File('$dirPath/${file.name}');
    }
    // 複製一份檔案到 newFile.path 路徑下
    await File(file.path!).copy(newFile.path);
    return newFile;
  }

  Future<bool> deleteFile({required File file}) async {
    final isExists = await fileIsExists(file: file);
    if (isExists) {
      await file.delete();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteDirectory({required Directory directory}) async {
    final isExists = await directoryIsExists(directory: directory);
    if (isExists) {
      await directory.delete(recursive: true);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> fileIsExists({required File file}) async {
    final isExists = await file.exists();
    return isExists;
  }

  Future<bool> directoryIsExists({required Directory directory}) async {
    final isExists = await directory.exists();
    return isExists;
  }

  String getFileName({required File file}) {
    final name = p.basename(file.path);
    return name;
  }

  Future<File> changeFileName(
      {required File file, required String newName}) async {
    var path = file.path;
    int lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    String newPath = path.substring(0, lastSeparator) + '/$newName';
    return await file.rename(newPath);
  }

  // 讀檔案內容
  Future<String> readFileAsString({required File file}) async {
    final result = await file.readAsString();
    return result;
  }

  // 將 content (檔案內容)寫入至 path 下
  Future<File> writeFileAsString(
      {required String content, required String path}) async {
    final file = File(path);
    await file.writeAsString(content);
    return file;
  }

  // 解壓縮檔案
  Future<List<dynamic>> extractZipFile(
      {required String destinationDirPath, required String zipFilePath}) async {
    final zipFile = File(zipFilePath);
    final destinationDir = Directory(destinationDirPath);
    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: destinationDir,
          onExtracting: (zipEntry, progress) {
            print('進度 progress: ${progress.toStringAsFixed(1)}%');
            print('名稱 name: ${zipEntry.name}');
            print('是目錄嗎 isDirectory: ${zipEntry.isDirectory}');
            print(
                'modificationDate: ${zipEntry.modificationDate!.toLocal().toIso8601String()}');
            print('uncompressedSize: ${zipEntry.uncompressedSize}');
            print('compressedSize: ${zipEntry.compressedSize}');
            print('compressionMethod: ${zipEntry.compressionMethod}');
            print('crc: ${zipEntry.crc}');
            return ZipFileOperation.includeItem;
          });
      return await getDirFileList(specifiedDir: destinationDir);
    } catch (e) {
      print('解壓縮檔案失敗');
      print(e);
      return ['Extract ZIP fail'];
    }
  }
}
