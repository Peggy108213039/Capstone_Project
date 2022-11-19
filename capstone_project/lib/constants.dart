// APP Color
import 'package:capstone_project/models/map/user_location.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/services/polyline_coordinates_model.dart';
import 'package:latlong2/latlong.dart';

const PrimaryDarkGreen = Color.fromARGB(255, 71, 79, 41);
const PrimaryMiddleGreen = Color.fromARGB(255, 100, 112, 55);
const PrimaryLightGreen = Color.fromARGB(255, 135, 142, 109);
const PrimaryLightYellow = Color.fromARGB(255, 255, 250, 217);
const PrimaryMiddleYellow = Color.fromARGB(255, 244, 214, 145);
const PrimaryBrown = Color.fromARGB(255, 119, 89, 17);
const kAnimationDuration = Duration(milliseconds: 200);

// APP primary color
const darkGreen2 = Color.fromARGB(255, 49, 96, 100); // #316064
const darkGreen1 = Color.fromARGB(255, 78, 135, 140); // #4E878C
const middleGreen = Color.fromARGB(255, 101, 184, 145); // #65b891
const lightGreen2 = Color.fromARGB(255, 147, 229, 171); // #93e5ab
const lightGreen1 = Color.fromARGB(255, 181, 255, 225); // #b5ffe1
const lightGreen0 = Color.fromARGB(255, 195, 255, 231); // #c3ffe7

// menu background color
const menuDarkGreenColor = Color.fromARGB(255, 34, 65, 68); // #224144

// activity color
const grassGreen = Color.fromARGB(255, 78, 140, 99); // # 4E8C63
const activityGreen = Color.fromARGB(255, 173, 235, 192); // #ADEBC0

// button color
const unselectedColor = Colors.white;
const selectedColor = Color.fromARGB(255, 255, 192, 0);

// default background color
const transparentColor = Colors.transparent;
const semiTransparentColor = Color.fromARGB(150, 255, 255, 255);

// UI image
const defaultBackgroundImage =
    AssetImage('assets/images/background/default_bg.png');
const introBackgroundImage =
    AssetImage('assets/images/background/intro_bg.png');
const activityListImage =
    AssetImage('assets/images/background/activity_list_bg.png');
const trackListImage = AssetImage('assets/images/background/track_list_bg.png');
const defaultUserImage = AssetImage("assets/images/user.png");

// logo image
const appNameImg = AssetImage('assets/images/logo_icons/appName.png');
const logoImg = AssetImage('assets/images/logo_icons/logo.png');
const logoNameImg = AssetImage('assets/images/logo_icons/logo_and_name.png');

// icon image
const addIcon = AssetImage('assets/images/other_icons/add.png');
const arIcon = AssetImage('assets/images/other_icons/AR.png');
const backIcon = AssetImage('assets/images/other_icons/back.png');
const backIcon2 = AssetImage('assets/images/other_icons/back2.png');
const cameraIcon = AssetImage('assets/images/other_icons/camera.png');
const deleteIcon = AssetImage('assets/images/other_icons/delete.png');
const editIcon = AssetImage('assets/images/other_icons/edit.png');
const endIcon = AssetImage('assets/images/other_icons/end.png');
const insertIcon = AssetImage('assets/images/other_icons/insert.png');
const layerIcon = AssetImage('assets/images/other_icons/layer.png');
const notificationIcon =
    AssetImage('assets/images/other_icons/notification.png');
const positionIcon = AssetImage('assets/images/other_icons/position.png');
const settingIcon = AssetImage('assets/images/other_icons/setting.png');
const startIcon = AssetImage('assets/images/other_icons/start.png');

// 軌跡頁面
bool hasTrackCheckTable = false;
List serverTrackData = [];

// 開始活動
late LatLng previousPoint;
bool havePreviousPoint = false;
PolylineCoordinates polyline = PolylineCoordinates(); // 紀錄使用者的 polyline
List<Map<String, dynamic>> activityPolyLineList = []; // 紀錄同行者的 polyline

// 地圖
UserLocation defaultLocation = UserLocation(
    latitude: 23.94981257,
    longitude: 120.92764976,
    altitude: 572.92668105,
    currentTime: UserLocation.getCurrentTime());
UserLocation currentLocation = defaultLocation;
UserLocation userLocation = defaultLocation;
