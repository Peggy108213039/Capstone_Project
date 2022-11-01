import 'package:capstone_project/models/activity/activity_model.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditActivity extends StatefulWidget {
  const EditActivity({Key? key}) : super(key: key);

  @override
  State<EditActivity> createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String activName = '';
  DateTime? activTime;
  String activTrack = '';
  String activPartner = '';
  String warningDistance = '50';
  var warningTime = '3';
  // bool hasTrackData = false;

  List<DropdownMenuItem<String>> activTrackList = [];

  List<DropdownMenuItem<String>> warnDistance = const [
    DropdownMenuItem(child: Text("50 公尺"), value: "50"),
    DropdownMenuItem(child: Text("100 公尺"), value: "100"),
    DropdownMenuItem(child: Text("150 公尺"), value: "150"),
    DropdownMenuItem(child: Text("200 公尺"), value: "200"),
    DropdownMenuItem(child: Text("300 公尺"), value: "300"),
    DropdownMenuItem(child: Text("400 公尺"), value: "400"),
    DropdownMenuItem(child: Text("500 公尺"), value: "500"),
  ];
  List<DropdownMenuItem<String>> warnTimeList = const [
    DropdownMenuItem(child: Text("3 分鐘"), value: "3"),
    DropdownMenuItem(child: Text("5 分鐘"), value: "5"),
    DropdownMenuItem(child: Text("10 分鐘"), value: "10"),
    DropdownMenuItem(child: Text("15 分鐘"), value: "15"),
    DropdownMenuItem(child: Text("20 分鐘"), value: "20"),
    DropdownMenuItem(child: Text("25 分鐘"), value: "25"),
    DropdownMenuItem(child: Text("30 分鐘"), value: "30"),
    DropdownMenuItem(child: Text("45 分鐘"), value: "45"),
    DropdownMenuItem(child: Text("60 分鐘"), value: "60"),
  ];

  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final int lastYear = 2050;

  // @override
  // void initState() {
  //   // implement initState
  //   super.initState();
  //   // getTrackData(); // 抓軌跡資料表下的資料
  // }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    print('arguments $arguments');

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('編輯活動'),
        ),
        backgroundColor: Colors.indigoAccent.shade100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: '返回',
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildActivName(initValue: arguments['activity_name']),
                buildActivTime(
                    initValue: DateTime.parse(arguments['activity_time'])),
                buildActivTrack(currentTrackID: arguments['tID']),
                buildActivPartner(), // FIXME 同行成員
                buildWarningDistance(initValue: arguments['warning_distance']),
                buildWarningTime(initValue: arguments['warning_time']),
                mySpace(100),
                ElevatedButton(
                  child: const Text('確認修改'),
                  onPressed: () {
                    print('確認修改');
                    pushSubmitBtn(aID: arguments['aID']);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent.shade100),
                )
              ],
            )),
      )),
    );
  }

  SizedBox mySpace(double num) {
    return SizedBox(height: num);
  }

  Future<Map<String, bool>> getTrackData(
      {required String currentTrackID}) async {
    late List? queryTrackTable = []; // 軌跡資料表下的資料
    await SqliteHelper.open; // 開啟資料庫
    queryTrackTable = await SqliteHelper.queryAll(tableName: 'track');
    print('getTrackData() 軌跡資料表 $queryTrackTable');
    if (queryTrackTable == null) {
      return {'hasData': false};
    }
    if (activTrackList.isEmpty) {
      // 預設 activTrack 是 queryTrackTable 第一筆資料
      activTrack = queryTrackTable[0]['tID'].toString();
      for (var element in queryTrackTable) {
        if (element['tID'].toString() == currentTrackID) {
          activTrack = element['tID'].toString();
        }
        activTrackList.add(DropdownMenuItem(
          child: Text(element['track_name']),
          value: element['tID'].toString(),
        ));
      }
    }
    print('activTrack $activTrack');
    print('activTrackList $activTrackList');
    return {'hasData': true};
  }

  Widget buildActivName({required String initValue}) {
    return TextFormField(
      initialValue: initValue,
      decoration: const InputDecoration(labelText: '活動名稱'),
      validator: (value) {
        if (value!.isEmpty) {
          return '請輸入活動名稱';
        }
      },
      onSaved: (newValue) {
        activName = newValue!;
      },
    );
  }

  Widget buildActivTime({required DateTime initValue}) {
    return DateTimeFormField(
      initialValue: initValue,
      initialDate: DateTime.now(),
      dateFormat: dateFormat,
      decoration: const InputDecoration(labelText: '活動時間'),
      firstDate: DateTime.now(),
      lastDate: DateTime(lastYear),
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        if (value == null) {
          return '請填活動時間';
        }
      },
      onSaved: (newValue) {
        activTime = newValue;
      },
    );
  }

  Widget buildActivTrack({required String currentTrackID}) {
    print('\ncurrentTrackID  $currentTrackID\n');
    return FutureBuilder(
        future: getTrackData(currentTrackID: currentTrackID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField(
              decoration: const InputDecoration(labelText: '活動軌跡'),
              value: activTrack,
              items: activTrackList,
              onChanged: (String? value) {
                activTrack = value!;
              },
              validator: (String? value) {
                if (value!.isEmpty) {
                  return '請填活動時間';
                }
              },
              onSaved: (String? newValue) {
                activTrack = newValue!;
              },
            );
          } else {
            return const Center(child: Text('沒有軌跡資料'));
          }
        });
  }

  Widget buildActivPartner() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '同行成員'),
      validator: (value) {
        if (value!.isEmpty) {
          return '請輸入同行成員';
        }
      },
      onSaved: (newValue) {
        activPartner = newValue!;
      },
    );
  }

  Widget buildWarningDistance({required String initValue}) {
    warningDistance = initValue;
    return DropdownButtonFormField(
      decoration: const InputDecoration(labelText: '最遠距離'),
      value: warningDistance,
      items: warnDistance,
      onChanged: (String? value) {
        warningDistance = value!;
      },
      validator: (String? value) {
        if (value!.isEmpty) {
          return '請填活動時間';
        }
      },
      onSaved: (String? newValue) {
        warningDistance = newValue!;
      },
    );
  }

  Widget buildWarningTime({required String initValue}) {
    return DropdownButtonFormField(
      decoration: const InputDecoration(labelText: '停留時間'),
      value: warningTime, // 設定初始值，要與列表 (items) 中的 value 是相同的
      items: warnTimeList,
      onChanged: (String? value) {
        warningTime = value!;
      },
      validator: (String? value) {
        if (value!.isEmpty) {
          return '請填入活動時間';
        }
      },
      onSaved: (String? newValue) {
        warningTime = newValue!;
      },
    );
  }

  void pushSubmitBtn({required int aID}) async {
    print('確認修改按鈕');
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    final newActivityData = Activity(
            uID: '0',
            activity_name: activName,
            activity_time: activTime.toString(),
            tID: activTrack,
            warning_distance: warningDistance,
            warning_time: warningTime)
        .toMap();
    // FIXME 編輯 server 同行成員資料
    print('修改後的活動資料  $newActivityData');
    await SqliteHelper.update(
        tableName: 'activity',
        updateData: newActivityData,
        tableIdName: 'aID',
        updateID: aID);
    Navigator.pushNamed(context, "/MyBottomBar3");
  }
}
