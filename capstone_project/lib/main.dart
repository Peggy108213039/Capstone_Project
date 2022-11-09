import 'package:capstone_project/bottom_bar.dart';
import 'package:capstone_project/ui/activity/activity_page.dart';
import 'package:capstone_project/ui/activity/add_activity.dart';
import 'package:capstone_project/ui/activity/edit_activity.dart';
import 'package:capstone_project/ui/activity/show_activity_data.dart';
import 'package:capstone_project/ui/map/camera/take_picture_screen.dart';
import 'package:capstone_project/ui/map/locationProvider.dart';
import 'package:capstone_project/ui/map/offline_map/add_offline_map.dart';
import 'package:capstone_project/ui/map/offline_map/download_offline_map.dart';
import 'package:capstone_project/ui/map/screens/ar_test.dart';
import 'package:capstone_project/ui/track/show_track_data_page.dart';
import 'package:capstone_project/ui/track/track_page.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/ui/login_page.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    // 垂直固定
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
          '/MapPage': (context) => const LocationProvider(
                mapService: 'FlutterMapPage',
              ),
          '/StartActivity': (context) => const LocationProvider(
                mapService: 'StartActivity',
              ),
          '/OfflineMapPage': (context) => const LocationProvider(
                mapService: 'OfflineMapPage',
              ),
          '/TrackPage': (context) => const TrackPage(),
          '/ActivityPage': (context) => const ActivityPage(),
          '/AddActivityPage': (context) => const AddActivityPage(),
          '/ShowActivityData': (context) => const ShowActivityData(),
          '/EditActivityData': (context) => const EditActivity(),
          // '/ShowTrackDataPage': (context) => const ShowTrackDataPage(),
          '/MyBottomBar1': ((context) =>
              const MyBottomBar(i: 1, firstTime: false)),
          '/MyBottomBar3': ((context) =>
              const MyBottomBar(i: 3, firstTime: false)),
          '/MyBottomBar0': ((context) =>
              const MyBottomBar(i: 0, firstTime: false)),
          '/TakePhotoPage': ((context) => const TakePhotoPage()),
          '/TestOfflineMap': ((context) => const TestOfflineMap()),
          '/DownloadOfflineMap': ((context) => const DownloadOfflineMap()),
          // '/': (context) => MenuScreen(),
          '/AR': ((context) => const ArScreen()),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(platform: TargetPlatform.iOS),
        //home: SocketPage(),
        home: const LoginPage());
  }
}
