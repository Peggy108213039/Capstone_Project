import 'package:capstone_project/constants.dart';
import 'package:flutter/material.dart';

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
  String distance = '0';
  String velocity = '0';
  late double width;
  late List<dynamic>? trackData;

  @override
  void initState() {
    width = widget.width;
    trackData = widget.trackData; // 軌跡資料
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final totaltime = DateTime.parse(trackData?[0]['finish'])
        .difference(DateTime.parse(trackData?[0]['start']));
    final String durationTime = durationFormat(totaltime); // 步行總時間
    final int timeSecond = totaltime.inSeconds; // (秒)
    final double totalDistance =
        double.parse(trackData?[0]['total_distance']); // (公尺)
    if (timeSecond == 0) {
      velocity = 0.toString();
    } else {
      double _velocity = 0.0;
      double _distance = 0;
      _distance = totalDistance / 1000; // 公尺轉公里
      // 公里/小時
      _velocity = (_distance / timeSecond * 60 * 60);
      // print(' 公里/小時 distance $distance timeSecond $timeSecond');
      distance = _distance.toStringAsFixed(2);
      velocity = _velocity.toStringAsFixed(2);
    }

    return SizedBox(
      width: width / 10 * 9,
      height: width / 5 * 1.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 主軸 (直) 的排版
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 主軸 (橫) 的排版
            children: [
              myCard(width: width, s1: '距離', s2: distance, s3: distanceUnit),
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
      color: darkGreen2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: SizedBox(
        height: width / 10 * 2.3,
        width: width / 10 * 2.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Text(
            //   s1,
            //   style: TextStyle(
            //       color: const Color.fromARGB(200, 255, 255, 255),
            //       fontSize: wordSize2),
            // ),
            Text(
              s2,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: wordSize1,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              s3,
              style: TextStyle(
                  color: const Color.fromARGB(200, 255, 255, 255),
                  fontSize: wordSize2),
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
