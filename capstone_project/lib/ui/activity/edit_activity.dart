import 'package:capstone_project/models/activity/activity_model.dart';
import 'package:capstone_project/models/friend/friend_model.dart';
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

  String activName = '';
  String activTrack = '';
  String activPartner = '';
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
                // FIXME 同行成員
                buildActivPartner(
                    initMemberList:
                        arguments['members'].toString().split(', ')),
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

  Future<List<FriendModel?>> getFriendTable(
      {required List initMemberList}) async {
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

    List<FriendModel?> initList = [];
    for (var friend in queryFriendTable) {
      if (initMemberList.contains(friend['uID'].toString())) {
        initList.add(FriendModel(
            fID: friend['fID'],
            uID: friend['uID'],
            account: friend['account'],
            name: friend['name']));
      }
    }
    return initList;
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
    return ValueListenableBuilder(
        valueListenable: timeValidate,
        builder: (context, bool? value, child) {
          timeinput.text = dateFormat.format(initValue);
          return TextField(
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
        });
  }

  Future<DateTime?> pickDate({required DateTime initValue}) {
    return showDatePicker(
      context: context,
      initialDate: initValue, // 預設選取時間
      firstDate: DateTime.now(), // 起始時間
      lastDate: DateTime(lastYear),
    );
  }

  Future<TimeOfDay?> pickTime({required DateTime initValue}) {
    return showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: initValue.hour, minute: initValue.minute),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!);
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

  Widget buildActivPartner({required List initMemberList}) {
    return FutureBuilder(
        future: getFriendTable(initMemberList: initMemberList),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return MultiSelectBottomSheetField<FriendModel?>(
              key: multiSelectKey,
              buttonText: const Text("同行成員"),
              title: const Text("同行成員"),
              initialChildSize: 0.4,
              items: friendSelectItems, // 朋友下拉式選單
              initialValue: snapshot.data, // 選中的同行者
              listType: MultiSelectListType.CHIP,
              searchable: true,
              onConfirm: (values) {
                setState(() {
                  selectedPartner = values;
                });
              },
              onSaved: (newValue) {
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
                  setState(() {
                    selectedPartner.remove(value);
                  });
                },
              ),
            );
          } else {
            return const Center(child: Text('沒有朋友資料'));
          }
        });
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
    if (!formKey.currentState!.validate() ||
        !multiSelectKey.currentState!.validate() ||
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

    List members = [];
    for (var partner in selectedPartner) {
      members.add(partner!.uID);
    }
    final Map<String, String> newActivityData = {
      'activity_name': activName,
      'activity_time': timeinput.text,
      'tID': activTrack,
      'warning_distance': warningDistance,
      'warning_time': warningTime,
      'members': members.join(', ') // FIXME 同行成員
    };
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
