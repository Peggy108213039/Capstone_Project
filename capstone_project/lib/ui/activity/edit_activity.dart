import 'dart:convert';

import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/activity/activity_model.dart';
import 'package:capstone_project/models/friend/friend_model.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class EditActivity extends StatefulWidget {
  const EditActivity({Key? key}) : super(key: key);

  @override
  State<EditActivity> createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // final GlobalKey<FormFieldState> multiSelectKey = GlobalKey<FormFieldState>();

  String activName = '';
  String activTrack = '';
  String warningDistance = '50';
  var warningTime = '3';

  // DateTime? activTime;
  TextEditingController timeinput = TextEditingController();
  final ValueNotifier<bool> timeValidate = ValueNotifier<bool>(false);
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final int lastYear = 2050;

  List<DropdownMenuItem<String>> activTrackList = [];
  List<MultiSelectItem<FriendModel>> friendSelectItems = []; // 朋友清單轉為下拉式選單
  List<FriendModel?> selectedPartner = []; // 選中的同行者

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
    timeinput.text = "";
    super.initState();
  }

  @override
  void dispose() {
    timeValidate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    print('arguments $arguments');

    return Scaffold(
      backgroundColor: activityGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false, // 關閉預設的 leading button
        backgroundColor: grassGreen,
        title: const Center(
          child: Text('編輯活動'),
        ),
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
              children: [
                buildActivName(initValue: arguments['activity_name']),
                buildActivTime(
                    initValue: DateTime.parse(arguments['activity_time'])),
                buildActivTrack(currentTrackID: arguments['tID']),
                // buildActivPartner(
                //     initMemberList:
                //         arguments['members'].toString().split(', ')),
                buildWarningDistance(initValue: arguments['warning_distance']),
                buildWarningTime(initValue: arguments['warning_time']),
                mySpace(30),
                SizedBox(
                  height: 45,
                  width: 100,
                  child: ElevatedButton(
                    child: const Text(
                      '確認',
                      style: TextStyle(color: darkGreen2, fontSize: 20),
                    ),
                    onPressed: () {
                      print('確認修改');
                      pushSubmitBtn(aID: int.parse(arguments['aID']));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                  ),
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
    await SqliteHelper.open; // 開啟資料庫
    List? queryTrackTable = await SqliteHelper.queryAll(tableName: 'track');
    queryTrackTable ??= [];
    if (queryTrackTable.isEmpty) {
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
    return {'hasData': true};
  }

  Future<bool> getFriendTable({required List initMemberList}) async {
    await SqliteHelper.open; // 開啟資料庫
    List? queryFriendTable = await SqliteHelper.queryAll(tableName: 'friend');
    queryFriendTable ??= [];
    if (friendSelectItems.isEmpty) {
      List<FriendModel> friendList = []; // 朋友清單
      for (var friend in queryFriendTable) {
        friendList.add(FriendModel(
            fID: friend['fID'],
            uID: friend['uID'],
            account: friend['account'],
            name: friend['name']));
      }
      friendSelectItems = friendList
          .map((friend) => MultiSelectItem<FriendModel>(friend, friend.name))
          .toList();
    }

    for (var friend in queryFriendTable) {
      if (initMemberList.contains(friend['uID'].toString())) {
        selectedPartner.add(FriendModel(
            fID: friend['fID'],
            uID: friend['uID'],
            account: friend['account'],
            name: friend['name']));
      }
    }
    print('selectedPartner   $selectedPartner');
    return true;
  }

  Widget buildActivName({required String initValue}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: grassGreen),
          borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        initialValue: initValue,
        style: const TextStyle(color: darkGreen2),
        decoration: const InputDecoration(labelText: '活動名稱'),
        validator: (value) {
          if (value!.isEmpty) {
            return '請輸入活動名稱';
          }
        },
        onSaved: (newValue) {
          activName = newValue!;
        },
      ),
    );
  }

  Widget buildActivTime({required DateTime initValue}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: grassGreen),
          borderRadius: BorderRadius.circular(15)),
      child: ValueListenableBuilder(
          valueListenable: timeValidate,
          builder: (context, bool? value, child) {
            timeinput.text = dateFormat.format(initValue);
            return TextField(
              style: const TextStyle(color: darkGreen2),
              controller: timeinput, //editing controller of this TextField
              decoration: InputDecoration(
                  labelText: '活動時間', errorText: value! ? '請選擇活動時間' : null),
              readOnly: true,
              onTap: () async {
                String _dateTime = await pickDateTime(initValue: initValue);
                timeinput.text = _dateTime;
              },
              onChanged: (value) {
                timeinput.text = value;
              },
            );
          }),
    );
  }

  Future<DateTime?> pickDate({required DateTime initValue}) {
    return showDatePicker(
      context: context,
      initialDate: initValue, // 預設選取時間
      firstDate: DateTime.now(), // 起始時間
      lastDate: DateTime(lastYear),
      builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: middleGreen),
          ),
          child: child!),
    );
  }

  Future<TimeOfDay?> pickTime({required DateTime initValue}) {
    return showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: initValue.hour, minute: initValue.minute),
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

  Future<String> pickDateTime({required DateTime initValue}) async {
    DateTime? date = await pickDate(
        initValue: DateTime(initValue.year, initValue.month, initValue.day));
    if (date == null) return '';
    TimeOfDay? time = await pickTime(initValue: initValue);
    if (time == null) return '';
    final DateTime dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    return dateFormat.format(dateTime);
  }

  Widget buildActivTrack({required String currentTrackID}) {
    print('\ncurrentTrackID  $currentTrackID\n');
    return FutureBuilder(
        future: getTrackData(currentTrackID: currentTrackID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
                    return '請填活動時間';
                  }
                },
                onSaved: (String? newValue) {
                  activTrack = newValue!;
                },
              ),
            );
          } else {
            return const Center(child: Text('沒有軌跡資料'));
          }
        });
  }

  // Widget buildActivPartner({required List initMemberList}) {
  //   return Container(
  //     margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
  //     decoration: BoxDecoration(
  //         border: Border.all(width: 3, color: grassGreen),
  //         borderRadius: BorderRadius.circular(15)),
  //     child: FutureBuilder(
  //         future: getFriendTable(initMemberList: initMemberList),
  //         builder: (BuildContext context, AsyncSnapshot snapshot) {
  //           if (snapshot.hasData) {
  //             return MultiSelectBottomSheetField<FriendModel?>(
  //               key: multiSelectKey,
  //               items: friendSelectItems, // 朋友下拉式選單
  //               initialValue: selectedPartner, // 初始值 : 選中的同行者
  //               buttonText: const Text(
  //                 "同行成員",
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               buttonIcon: const Icon(Icons.arrow_drop_down),
  //               decoration: const BoxDecoration(
  //                   color: middleGreen,
  //                   borderRadius: BorderRadius.all(Radius.circular(10))),
  //               confirmText: const Text(
  //                 '確認',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               cancelText: const Text(
  //                 '取消',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               title: const Text(
  //                 "選擇同行成員",
  //                 style: TextStyle(
  //                     color: lightGreen0, fontWeight: FontWeight.bold),
  //               ),
  //               initialChildSize: 0.38,
  //               maxChildSize: 0.6,
  //               selectedColor: Colors.white,
  //               selectedItemsTextStyle: const TextStyle(color: middleGreen),
  //               unselectedColor: Colors.white,
  //               checkColor: Colors.white,
  //               itemsTextStyle: const TextStyle(color: Colors.black),
  //               backgroundColor: darkGreen1,
  //               searchHint: '搜尋好友',
  //               searchHintStyle: const TextStyle(color: Colors.white),
  //               searchTextStyle: const TextStyle(color: Colors.white),
  //               searchIcon: const Icon(
  //                 Icons.search,
  //                 color: Colors.white,
  //               ),
  //               closeSearchIcon: const Icon(
  //                 Icons.close,
  //                 color: Colors.white,
  //               ),

  //               listType: MultiSelectListType.CHIP,
  //               separateSelectedItems: true,
  //               searchable: true,
  //               onConfirm: (values) {
  //                 selectedPartner = values;
  //               },
  //               onSaved: (newValue) {
  //                 selectedPartner = newValue!;
  //               },
  //               // validator: (value) {
  //               //   if (value!.isEmpty) {
  //               //     return '請選同行者';
  //               //   }
  //               // },

  //               chipDisplay: MultiSelectChipDisplay(
  //                 items: selectedPartner
  //                     .map((member) => MultiSelectItem(member, member!.name))
  //                     .toList(),
  //                 chipColor: Colors.white,
  //                 textStyle: const TextStyle(color: grassGreen),
  //                 icon: const Icon(Icons.cancel_outlined, color: grassGreen),
  //                 scroll: true,
  //                 onTap: (value) {
  //                   selectedPartner.remove(value);
  //                   return selectedPartner;
  //                 },
  //               ),
  //             );
  //           } else {
  //             return const Center(child: Text('沒有朋友資料'));
  //           }
  //         }),
  //   );
  // }

  Widget buildWarningDistance({required String initValue}) {
    warningDistance = initValue;
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
        onSaved: (String? newValue) {
          warningDistance = newValue!;
        },
      ),
    );
  }

  Widget buildWarningTime({required String initValue}) {
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
        onSaved: (String? newValue) {
          warningTime = newValue!;
        },
      ),
    );
  }

  void pushSubmitBtn({required int aID}) async {
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
    print('修改 server 活動資料 1');
    final Map<String, dynamic> newServerActivityData = {
      'aID': aID.toString(),
      'uID': UserData.uid.toString(),
      'activity_name': activName,
      'activity_time': timeinput.text,
      'tID': activTrack,
      'warning_distance': warningDistance,
      'warning_time': warningTime,
      // 'members': jsonEncode(members)
    };
    print('修改 server 活動資料 2 $newServerActivityData');
    // FIXME
    List result =
        await APIService.updateActivity(content: newServerActivityData);
    print('result $result');
    print('修改 server 活動資料 3');
    if (result[0]) {
      final Map<String, String> newActivityData = {
        'uID': UserData.uid.toString(),
        'activity_name': activName,
        'activity_time': timeinput.text,
        'tID': activTrack,
        'warning_distance': warningDistance,
        'warning_time': warningTime,
        // 'members': members.join(', ')
      };
      print('修改後的活動資料  $newActivityData');
      await SqliteHelper.update(
          tableName: 'activity',
          updateData: newActivityData,
          tableIdName: 'aID',
          updateID: aID);
      Navigator.pop(context);
    } else {
      print('$result 在 server 新增活動失敗');
    }
  }
}
