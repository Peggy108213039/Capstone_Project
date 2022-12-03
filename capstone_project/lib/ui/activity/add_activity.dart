import 'dart:convert';

import 'package:capstone_project/constants.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:capstone_project/models/friend/friend_model.dart';
import 'package:capstone_project/models/activity/activity_model.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:provider/provider.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({Key? key}) : super(key: key);

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> multiSelectKey = GlobalKey<FormFieldState>();

  String activName = '';
  String activTrack = '';
  String warningDistance = '30';
  var warningTime = '1';

  TextEditingController timeinput = TextEditingController();
  final ValueNotifier<bool> timeValidate = ValueNotifier<bool>(false);
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final int lastYear = 2050;

  late MyAlertDialog noTrackListDialog; // 提醒視窗：沒有軌跡清單
  late MyAlertDialog noFriendListDialog; // 提醒視窗：沒有朋友清單

  List<DropdownMenuItem<String>> activTrackList = [];
  List<MultiSelectItem<FriendModel>> friendSelectItems = []; // 朋友清單轉為下拉式選單
  List<FriendModel?> selectedPartner = []; // 選中的同行者

  List<DropdownMenuItem<String>> warnDistance = const [
    DropdownMenuItem(child: Text("30 公尺"), value: "30"),
    DropdownMenuItem(child: Text("50 公尺"), value: "50"),
    DropdownMenuItem(child: Text("100 公尺"), value: "100"),
    DropdownMenuItem(child: Text("150 公尺"), value: "150"),
    DropdownMenuItem(child: Text("200 公尺"), value: "200"),
    DropdownMenuItem(child: Text("300 公尺"), value: "300"),
    DropdownMenuItem(child: Text("400 公尺"), value: "400"),
    DropdownMenuItem(child: Text("500 公尺"), value: "500"),
  ];
  List<DropdownMenuItem<String>> warnTimeList = const [
    DropdownMenuItem(child: Text("1 分鐘"), value: "1"),
    DropdownMenuItem(child: Text("3 分鐘"), value: "3"),
    DropdownMenuItem(child: Text("5 分鐘"), value: "5"),
    DropdownMenuItem(child: Text("10 分鐘"), value: "10"),
    DropdownMenuItem(child: Text("15 分鐘"), value: "15"),
    DropdownMenuItem(child: Text("20 分鐘"), value: "20"),
    DropdownMenuItem(child: Text("25 分鐘"), value: "25"),
    DropdownMenuItem(child: Text("30 分鐘"), value: "30"),
  ];

  @override
  void initState() {
    timeinput.text = "";
    getTrackData(); // 抓軌跡資料表下的資料
    super.initState();
  }

  @override
  void dispose() {
    timeValidate.dispose();
    super.dispose();
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
          titleFontSize: 30,
          contentText: '請到軌跡頁面匯入軌跡',
          contentFontSize: 20,
          btn1Text: '確認',
          btn2Text: '');
      await noTrackListDialog.show();
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
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: grassGreen),
          borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        style: const TextStyle(color: darkGreen2),
        decoration: const InputDecoration(labelText: '活動名稱'),
        validator: (value) {
          if (value!.isEmpty) {
            return '請填入活動名稱';
          }
        },
        onSaved: (value) {
          activName = value!;
        },
      ),
    );
  }

  Widget buildActivTime() {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: grassGreen),
          borderRadius: BorderRadius.circular(15)),
      child: ValueListenableBuilder(
          valueListenable: timeValidate,
          builder: (context, bool? value, child) {
            return TextField(
              style: const TextStyle(color: darkGreen2),
              controller: timeinput, //editing controller of this TextField
              decoration: InputDecoration(
                  labelText: '活動時間', errorText: value! ? '請選擇活動時間' : null),
              readOnly: true,
              onTap: () async {
                String _dateTime = await pickDateTime();
                timeinput.text = _dateTime;
              },
              onChanged: (value) {
                timeinput.text = value;
              },
            );
          }),
    );
  }

  Future<DateTime?> pickDate() {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now(), // 預設選取時間
        firstDate: DateTime.now(), // 起始時間
        lastDate: DateTime(lastYear),
        builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: middleGreen),
              ),
              child: child!,
            ));
  }

  Future<TimeOfDay?> pickTime() {
    return showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: middleGreen),
            ),
            child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: false),
                child: child!),
          );
        });
  }

  Future<String> pickDateTime() async {
    DateTime? date = await pickDate();
    if (date == null) return '';
    TimeOfDay? time = await pickTime();
    if (time == null) return '';
    final DateTime dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return dateFormat.format(dateTime);
  }

  Widget buildActivTrack() {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: grassGreen),
          borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField(
        decoration: const InputDecoration(labelText: '活動軌跡'),
        value: activTrack,
        items: activTrackList,
        style: const TextStyle(color: darkGreen2, fontSize: 17),
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
      ),
    );
  }

  Widget buildActivPartner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: grassGreen),
          borderRadius: BorderRadius.circular(15)),
      child: MultiSelectBottomSheetField<FriendModel?>(
        key: multiSelectKey,
        buttonText: const Text(
          "同行成員",
          style: TextStyle(color: Colors.white),
        ),
        buttonIcon: const Icon(Icons.arrow_drop_down),
        decoration: const BoxDecoration(
            color: middleGreen,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        confirmText: const Text(
          '確認',
          style: TextStyle(color: Colors.white),
        ),
        cancelText: const Text(
          '取消',
          style: TextStyle(color: Colors.white),
        ),
        title: const Text(
          "選擇同行成員",
          style: TextStyle(color: lightGreen0, fontWeight: FontWeight.bold),
        ),
        initialChildSize: 0.38,
        maxChildSize: 0.6,

        selectedColor: Colors.white,
        selectedItemsTextStyle: const TextStyle(color: middleGreen),

        unselectedColor: Colors.white,
        checkColor: Colors.white,
        itemsTextStyle: const TextStyle(color: Colors.black),

        backgroundColor: darkGreen1,

        searchHint: '搜尋好友',
        searchHintStyle: const TextStyle(color: Colors.white),
        searchTextStyle: const TextStyle(color: Colors.white),
        searchIcon: const Icon(
          Icons.search,
          color: Colors.white,
        ),
        closeSearchIcon: const Icon(
          Icons.close,
          color: Colors.white,
        ),

        items: friendSelectItems, // 朋友下拉式選單
        initialValue: selectedPartner, // 選中的同行者
        listType: MultiSelectListType.CHIP,
        separateSelectedItems: true,
        searchable: true,
        onConfirm: (values) {
          selectedPartner = values;
        },
        onSaved: (newValue) {
          print('onSaved');
          selectedPartner = newValue!;
        },
        // validator: (value) {
        //   if (value!.isEmpty) {
        //     return '請選同行者';
        //   }
        // },
        chipDisplay: MultiSelectChipDisplay(
          chipColor: Colors.white,
          textStyle: const TextStyle(color: darkGreen2),
          icon: const Icon(Icons.cancel_outlined, color: grassGreen),
          scroll: true,
          onTap: (value) {
            selectedPartner.remove(value);
            return selectedPartner;
          },
        ),
      ),
    );
  }

  Widget buildWarningDistance() {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: grassGreen),
          borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField(
        decoration: const InputDecoration(labelText: '最遠距離'),
        style: const TextStyle(color: darkGreen2, fontSize: 17),
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
      ),
    );
  }

  Widget buildWarningTime() {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: grassGreen),
          borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField(
        decoration: const InputDecoration(labelText: '停留時間'),
        style: const TextStyle(color: darkGreen2, fontSize: 17),
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
      ),
    );
  }

  void pushSubmitBtn() async {
    if (!formKey.currentState!.validate() ||
        // !multiSelectKey.currentState!.validate() ||
        timeinput.text.isEmpty) {
      if (timeinput.text.isEmpty) {
        timeValidate.value = true;
      } else {
        timeValidate.value = false;
      }
      return;
    }
    formKey.currentState!.save();
    multiSelectKey.currentState!.save();
    List<int> members = [];
    if (selectedPartner.isNotEmpty) {
      for (var partner in selectedPartner) {
        members.add(partner!.uID);
      }
    }
    members.add(UserData.uid);
    final ActivityRequestModel newServerActivityData = ActivityRequestModel(
        uID: UserData.uid.toString(),
        activity_name: activName,
        activity_time: timeinput.text,
        tID: activTrack,
        warning_distance: warningDistance,
        warning_time: warningTime,
        // warning_distance: '0',
        // warning_time: '0',
        members: members);
    // 插入 server 資料庫
    List result =
        await APIService.addActivity(content: newServerActivityData.toMap());
    if (result[0]) {
      // 插入 sqlite 資料庫
      // final Activity newLocalActivityData = Activity(
      //     aID: result[1]['aID'].toString(),
      //     uID: UserData.uid.toString(),
      //     activity_name: activName,
      //     activity_time: timeinput.text,
      //     finish_activity_time: 'null',
      //     start_activity_time: 'null',
      //     tID: activTrack,
      //     warning_distance: warningDistance,
      //     warning_time: warningTime,
      //     members: members.join(', '));
      // await SqliteHelper.insert(
      //     tableName: 'activity', insertData: newLocalActivityData.toMap());
      Navigator.pop(context);
    } else {
      print('$result 在 server 新增活動失敗');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: activityGreen,
        appBar: AppBar(
          automaticallyImplyLeading: false, // 關閉預設的 leading button
          backgroundColor: grassGreen,
          title: const Center(
              child: Text(
            '新增活動',
          )),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            color: transparentColor,
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
                  mySpace(30),
                  SizedBox(
                    height: 45,
                    width: 100,
                    child: ElevatedButton(
                      child: const Text(
                        '確認',
                        style: TextStyle(color: darkGreen2, fontSize: 20),
                      ),
                      onPressed: pushSubmitBtn,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
