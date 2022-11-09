import 'dart:convert';

import 'package:capstone_project/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:date_field/date_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:capstone_project/models/friend/friend_model.dart';
import 'package:capstone_project/models/activity/activity_model.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
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
  String warningDistance = '50';
  var warningTime = '3';

  late MyAlertDialog noTrackListDialog; // 提醒視窗：沒有軌跡清單
  late MyAlertDialog noFriendListDialog; // 提醒視窗：沒有朋友清單

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final int lastYear = 2050;

  List<DropdownMenuItem<String>> activTrackList = [];

  List<MultiSelectItem<FriendModel>> friendSelectItems = []; // 朋友清單轉為下拉式選單
  List<FriendModel?> selectedPartner = []; // 選中的同行者
  final GlobalKey<FormFieldState> multiSelectKey = GlobalKey<FormFieldState>();

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

  @override
  void initState() {
    // implement initState
    super.initState();
    getTrackData(); // 抓軌跡資料表下的資料
  }

  getTrackData() async {
    await SqliteHelper.open; // 開啟資料庫
    List? queryTrackTable = await SqliteHelper.queryAll(tableName: 'track');
    List? queryFriendTable = await SqliteHelper.queryAll(tableName: 'friend');
    queryTrackTable ??= [];
    queryFriendTable ??= [];
    if (queryTrackTable.isEmpty) {
      noTrackListDialog = MyAlertDialog(
          context: context,
          titleText: '沒有軌跡清單',
          contentText: '請到軌跡頁面匯入軌跡',
          btn1Text: '確認',
          btn2Text: '');
      await noTrackListDialog.show();
      Navigator.of(context).pop(true);
      return;
    }
    if (queryFriendTable.isEmpty) {
      noFriendListDialog = MyAlertDialog(
          context: context,
          titleText: '沒有朋友清單',
          contentText: '請到朋友頁面新增好友',
          btn1Text: '確認',
          btn2Text: '');
      await noFriendListDialog.show();
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      activTrack = queryTrackTable![0]['tID'].toString();
      for (var element in queryTrackTable) {
        activTrackList.add(DropdownMenuItem(
          child: Text(element['track_name']),
          value: element['tID'].toString(),
        ));
      }
      List<FriendModel> friendList = []; // 朋友清單
      for (var friend in queryFriendTable!) {
        friendList.add(FriendModel(
            fID: friend['fID'],
            uID: friend['uID'],
            account: friend['account'],
            name: friend['name']));
      }
      friendSelectItems = friendList
          .map((friend) => MultiSelectItem<FriendModel>(friend, friend.name))
          .toList();
      print('friendList $friendList');
    });
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

  // FIXME 活動時間
  Widget buildActivTime() {
    return DateTimeFormField(
      dateFormat: dateFormat,
      decoration: const InputDecoration(labelText: '活動時間'),
      firstDate: DateTime.now(), // 起始時間
      initialDate: DateTime.now(), // 預設選取時間
      lastDate: DateTime(lastYear),
      // mode: DateTimeFieldPickerMode.dateAndTime,
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        // print('時間 $value');
        if (value == null) {
          return '請填活動時間';
        }
      },
      onDateSelected: (value) {
        print(value);
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
        if (value!.isEmpty) {
          return '請填活動軌跡';
        }
      },
      onSaved: (String? value) {
        activTrack = value!;
      },
    );
  }

  Widget buildActivPartner() {
    return MultiSelectBottomSheetField<FriendModel?>(
      key: multiSelectKey,
      buttonText: const Text("同行成員"),
      title: const Text("同行成員"),
      initialChildSize: 0.4,
      items: friendSelectItems, // 朋友下拉式選單
      initialValue: selectedPartner, // 選中的同行者

      listType: MultiSelectListType.CHIP,
      searchable: true,
      onConfirm: (values) {
        print('onConfirm');
        setState(() {
          selectedPartner = values;
        });
      },
      onSaved: (newValue) {
        print('onConfirm');
        selectedPartner = newValue!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return '請選同行者';
        }
      },
      chipDisplay: MultiSelectChipDisplay(
        icon: const Icon(Icons.cancel_outlined),
        scroll: true,
        onTap: (value) {
          print('onTap');
          setState(() {
            selectedPartner.remove(value);
          });
        },
      ),
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
        if (value!.isEmpty) {
          return '請填最遠距離';
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
        if (value!.isEmpty) {
          return '請填停留時間';
        }
      },
      onSaved: (String? value) {
        warningTime = value!;
      },
    );
  }

  void pushSubmitBtn() async {
    print('確認按鈕');
    if (!formKey.currentState!.validate() ||
        !multiSelectKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    multiSelectKey.currentState!.save();
    List<String> members = [];
    for (var partner in selectedPartner) {
      members.add(partner!.uID.toString());
    }
    final newLocalActivityData = Activity(
            // FIXME: aID
            uID: UserData.uid.toString(),
            activity_name: activName,
            activity_time: dateFormat.format(activTime!),
            tID: activTrack,
            warning_distance: warningDistance,
            warning_time: warningTime,
            members: members.join(', '))
        .toMap();
    // final newServerActivityData = ActivityRequestModel(
    //         // FIXME: aID
    //         uID: UserData.uid.toString(),
    //         activity_name: activName,
    //         activity_time: dateFormat.format(activTime!),
    //         tID: activTrack,
    //         warning_distance: warningDistance,
    //         warning_time: warningTime,
    //         members: members)
    //     .toMap();

    final newServerActivityData = {
      'uID': UserData.uid.toString(),
      'activity_name': activName,
      'activity_time': dateFormat.format(activTime!),
      'tID': activTrack,
      'warning_distance': warningDistance,
      'warning_time': warningTime,
      'members': jsonEncode(members)
    };
    // 插入資料庫
    print('newServerActivityData\n$newServerActivityData');
    bool result = await APIService.addActivity(content: newServerActivityData);
    print('result $result');
    if (result) {
      await SqliteHelper.insert(
          tableName: 'activity', insertData: newLocalActivityData);
      Navigator.pushNamed(context, "/MyBottomBar3");
    } else {
      print('$result 在 server 新增活動失敗');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 關閉預設的 leading button
          backgroundColor: Colors.indigoAccent.shade100,
          title: const Center(
              child: Text(
            '新增活動',
          )),
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
