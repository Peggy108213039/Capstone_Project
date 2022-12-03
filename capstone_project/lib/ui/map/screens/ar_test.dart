
import 'package:capstone_project/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:latlong2/latlong.dart';
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

  int _counter = 0;
  void _incrementCounter(){
    setState(() {
      _counter++;
      dispose();
      initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute
        .of(context)
        ?.settings
        .arguments ??
        <String, dynamic>{}) as Map;

    print('=== AR gpsList ===');
    print(arguments['gpsList']);
    print('============');
    String titleText = "AR Screen" + _counter.toString();
    RouteProvider.get_GPS_route(arguments['gpsList']);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: middleGreen,
      appBar: AppBar(
        title: Text(titleText),
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
      floatingActionButton:  FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }

  // Callback that connects the created controller to the unity controller
  void _onUnityCreated(controller) {
    this._unityWidgetController = controller;
    //read().then((value) => setCustomRoute(value));
    setCustomRoute();
  }

  void setCustomRoute() {
    while (!RouteProvider.done) {
      print("Waiting route loading....");
    }
    String content = RouteProvider.route_string;
    print("Post Meg To Unity! \nContent: " + content);
    _unityWidgetController.postMessage(
        'RouteManager', 'GetRouteFromFlutter', content);
  }

  void onUnityMessage(message) {
    print('Received message from unity: ${message.toString()}');
  }

  void onUnitySceneLoaded(SceneLoaded scene) {
    print('Received scene loaded from unity: ${scene.name}');
    print('Received scene loaded from unity buildIndex: ${scene.buildIndex}');
  }

}

class RouteProvider{
  static bool done = false;
  static String route_string = "";

  static void get_GPS_route(List<LatLng> gps){
    if(route_string !="")
    {
      route_string = "";
    }
    print("========Get GPS!!===========");

    int len = gps.length;
    print("gps length: " + len.toString());

    for(int i = 0; i <len ; i++)
    {
      print("current index: " + i.toString());
      print("lat: " + gps[i].latitude.toString());
      print("lon: " + gps[i].longitude.toString());
      route_string += gps[i].latitude.toString() + ",";
      route_string += gps[i].longitude.toString() + " ";
    }
    done = true;
    print("result: " + route_string);
    print("=======Get GPS!!==========");
  }
}
