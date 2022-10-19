import 'package:capstone_project/models/activity/activity_model.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:capstone_project/services/sqlite_helper.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({Key? key}) : super(key: key);

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  String activName = '';
  DateTime? activTime;
  String activTrack = '';
  String activPartner = '';
  String warningDistance = '50';
  var warningTime = '3';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final int lastYear = 2050;
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
  late List? queryTrackTable = []; // 軌跡資料表下的資料

  @override
  void initState() {
    // implement initState
    super.initState();
    getTrackData(); // 抓軌跡資料表下的資料
  }

  getTrackData() async {
    await SqliteHelper.open; // 開啟資料庫
    queryTrackTable = await SqliteHelper.queryAll(tableName: 'track');
    print('活動資料表 ${await SqliteHelper.queryAll(tableName: 'activity')}');
    if (queryTrackTable == null) {
      return;
    }
    if (queryTrackTable!.isEmpty) {
      print('活動資料表為空');
      return;
    }
    // print('query Track Table ${queryTrackTable![0]['track_name']}');
    setState(() {
      activTrack = queryTrackTable![0]['tID'].toString();
      queryTrackTable!.forEach((element) {
        // print('element ${element['track_name']}');
        activTrackList.add(DropdownMenuItem(
          child: Text(element['track_name']),
          value: element['tID'].toString(),
        ));
      });
    });
    print('activTrack $activTrack');
    print('activTrackList $activTrackList');
    return queryTrackTable;
  }

  SizedBox mySpace(double num) {
    return SizedBox(height: num);
  }

  Widget buildActivName() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '活動名稱'),
      validator: (value) {
        if (value!.isEmpty) {
          return '請填入活動名稱';
        }
      },
      onSaved: (value) {
        activName = value!;
      },
    );
  }

  Widget buildActivTime() {
    return DateTimeFormField(
      dateFormat: dateFormat,
      decoration: const InputDecoration(labelText: '活動時間'),
      firstDate: DateTime.now(), // 起始時間
      initialDate: DateTime.now(), // 預設選取時間
      lastDate: DateTime(lastYear),
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        // print('時間 $value');
        if (value == null) {
          return '請填活動時間';
        }
      },
      onSaved: (value) {
        activTime = value;
      },
    );
  }

  Widget buildActivTrack() {
    return DropdownButtonFormField(
      decoration: const InputDecoration(labelText: '活動軌跡'),
      value: activTrack,
      items: activTrackList,
      onChanged: (String? value) {
        activTrack = value!;
      },
      validator: (String? value) {
        // print('活動軌跡 $value');
        if (value!.isEmpty) {
          return '請填活動時間';
        }
      },
      onSaved: (String? value) {
        activTrack = value!;
      },
    );
  }

  Widget buildActivPartner() {
    return TextFormField(
      decoration: const InputDecoration(labelText: '同行成員'),
      validator: (value) {
        if (value!.isEmpty) {
          return '請輸入同行成員';
        }
      },
      onSaved: (value) {
        activPartner = value!;
      },
    );
  }

  Widget buildWarningDistance() {
    return DropdownButtonFormField(
      decoration: const InputDecoration(labelText: '最遠距離'),
      value: warningDistance,
      items: warnDistance,
      onChanged: (String? value) {
        warningDistance = value!;
      },
      validator: (String? value) {
        // print('最遠距離 $value');
        if (value!.isEmpty) {
          return '請填活動時間';
        }
      },
      onSaved: (String? value) {
        warningDistance = value!;
      },
    );
  }

  Widget buildWarningTime() {
    return DropdownButtonFormField(
      decoration: const InputDecoration(labelText: '停留時間'),
      value: warningTime, // 設定初始值，要與列表 (items) 中的 value 是相同的
      items: warnTimeList,
      onChanged: (String? value) {
        warningTime = value!;
      },
      validator: (String? value) {
        // print('停留時間 $value');
        if (value!.isEmpty) {
          return '請填活動時間';
        }
      },
      onSaved: (String? value) {
        warningTime = value!;
      },
    );
  }

  void pushSubmitBtn() async {
    print('確認按鈕');
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
    // FIXME 新增同行成員資料
    // 插入資料庫
    await SqliteHelper.insert(
        tableName: 'activity', insertData: newActivityData);
    Navigator.pushNamed(context, "/MyBottomBar3");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigoAccent.shade100,
          title: const Center(
              child: Text(
            '新增活動',
          )),
          leading: IconButton(
            onPressed: () =>
                Navigator.of(context).pop(), // FIXME：context 要換成活動清單的 context
            icon: const Icon(Icons.arrow_back_rounded),
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
                children: <Widget>[
                  buildActivName(),
                  buildActivTime(),
                  buildActivTrack(),
                  buildActivPartner(),
                  buildWarningDistance(),
                  buildWarningTime(),
                  mySpace(100),
                  ElevatedButton(
                    child: const Text('確認'),
                    onPressed: pushSubmitBtn,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent.shade100),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
