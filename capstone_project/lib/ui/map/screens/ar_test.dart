import 'package:capstone_project/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ArScreen extends StatefulWidget {
  const ArScreen({Key? key}) : super(key: key);

  @override
  _ArScreenState createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  late UnityWidgetController _unityWidgetController;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unityWidgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    print('=== AR gpsList ===');
    print(arguments['gpsList']);
    print('============');
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: middleGreen,
      appBar: AppBar(
        title: const Text('Ar Screen'),
        backgroundColor: middleGreen,
        shadowColor: transparentColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))),
      ),
      body: Container(
          color: transparentColor,
          margin: const EdgeInsets.all(0),
          child: Stack(
            children: [
              UnityWidget(
                onUnityCreated: _onUnityCreated,
                onUnityMessage: onUnityMessage,
                //onUnitySceneLoaded: onUnitySceneLoaded,
                useAndroidViewSurface: true,
                borderRadius: const BorderRadius.all(Radius.circular(70)),
              ),
            ],
          )),
    );
  }

  // Callback that connects the created controller to the unity controller
  void _onUnityCreated(controller) {
    this._unityWidgetController = controller;
    read().then((value) => setCustomRoute(value));
  }

  void setCustomRoute(Content) {
    print("Post Meg To Unity! \nContent: " + Content);
    _unityWidgetController.postMessage(
        'RouteManager', 'GetRouteFromFlutter', Content);
  }

  void onUnityMessage(message) {
    print('Received message from unity: ${message.toString()}');
  }

  void onUnitySceneLoaded(SceneLoaded scene) {
    print('Received scene loaded from unity: ${scene.name}');
    print('Received scene loaded from unity buildIndex: ${scene.buildIndex}');
  }

  Future<String> read() async {
    File? file = await FileProvider.getNewFile();
    print("Success Get File!");

    print("\n-----------------------------------------------\n");

    print("Start To Read File!!!!");
    String fileText = '';
    if (file != '') {
      try {
        fileText = await file!.readAsString();
      } catch (e) {
        print("Couldn't read file!");
        print("Exception: " + e.toString());
      }
    }
    return fileText;
    // String text;
    // try {
    //   final Directory directory = await getApplicationDocumentsDirectory();
    //   print("Directory PATH: " + directory.path);
    //   final File file = File('${directory.path}/customRoute.xml');
    //   text = await file.readAsString();
    // }catch(e){
    //   print("Couldn't read file!");
    //   print("Exception: " + e.toString());
    // }
  }
}

class FileProvider {
  static File? newFile;
  static bool isSavingFile = false;

  static Future<Directory> getAppDir() async {
    Directory directory = await getApplicationDocumentsDirectory();
    Directory dir = Directory('${directory.path}/dirName');
    var isExist = await dir.exists();
    if (!isExist) {
      print("Create dir!!!");
      await dir.create(recursive: true);
    }
    print("Directory: " + dir.path);
    return dir;
  }

  static Future<File?> saveFile() async {
    Directory dir = await getAppDir();

    try {
      String fileName = 'customRoute.kml';
      Directory? external = await getExternalStorageDirectory();
      print("External Directory: " + external!.path);
      final File file = File('${external.path}/$fileName');

      newFile = File('${dir.path}/$fileName');
      await File(file.path).copy(newFile!.path);
      isSavingFile = true;
    } catch (e) {
      print("Cannot save file!!!!");
      print("Exception: " + e.toString());
    }

    return newFile;
  }

  static Future<File?> getNewFile() async {
    File? file = await saveFile();
    if (file == null) {
      print("File is NULL!!!");
    } else {
      print("File path: " + file.path);
    }
    return newFile;
  }
}
