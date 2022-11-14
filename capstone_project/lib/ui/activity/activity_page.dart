import 'package:capstone_project/constants.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  bool _visible = false;
  late List? activTable = []; // 活動資料表下的資料

  @override
  void initState() {
    // implement initState
    super.initState();
  }

  getActivData() async {
    await SqliteHelper.open; // 開啟資料庫
    activTable = await SqliteHelper.queryAll(tableName: 'activity');
    if (activTable == null) {
      return;
    }
    return activTable;
  }

  void pushDelete(int idx, BuildContext context) async {
    final deleteActiv = activTable![idx];
    final String deleteActivName = deleteActiv['activity_name'];
    final int deleteAID = int.parse(deleteActiv['aID']);
    bool? toDelete = await _showAlertDialog(
        context: context,
        myTitle: '刪除軌跡',
        myContent: '確定要刪除活動 $deleteActivName ?',
        btn1Text: '刪除',
        btn2Text: '取消');
    toDelete ??= false;
    if (toDelete) {
      final deleteServerActivity = {
        'uID': UserData.uid.toString(),
        'aID': deleteAID.toString()
      };
      final List deleteActivResponse =
          await APIService.deleteActivity(content: deleteServerActivity);
      if (deleteActivResponse[0]) {
        var result = await SqliteHelper.delete(
            tableName: 'activity', tableIdName: 'aID', deleteId: deleteAID);
        activTable = await SqliteHelper.queryAll(tableName: 'activity');
        setState(() {});
      } else {
        print('delete Activ Response ${deleteActivResponse[1]}');
      }
    } else {
      print('不要刪除軌跡');
      return;
    }
  }

  // 跳出小小對話框
  Future<bool?> _showAlertDialog({
    required BuildContext context,
    required String? myTitle,
    required String? myContent,
    required String? btn1Text,
    required String? btn2Text,
  }) {
    // Btn1
    Widget btn1;
    if (btn1Text == '') {
      btn1 = const SizedBox.shrink();
    } else {
      btn1 = TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(btn1Text!));
    }

    // Btn1
    Widget btn2;
    if (btn2Text == '') {
      btn2 = const SizedBox.shrink();
    } else {
      btn2 = TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(btn2Text!));
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(myTitle!),
            content: Text(myContent!),
            actions: [btn1, btn2],
          );
        });
  }

  Widget showAllActivities() {
    return FutureBuilder(
        future: getActivData(),
        builder: (BuildContext context, AsyncSnapshot snap) {
          if (snap.hasData && snap.data != []) {
            List list = snap.data;
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, idx) {
                return Column(
                  children: <Widget>[
                    Card(
                      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      color: transparentColor,
                      shadowColor: transparentColor,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            image: const DecorationImage(
                                image: activityListImage, fit: BoxFit.cover)),
                        child: ListTile(
                          title: Text(
                            list[idx]['activity_name'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Container(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              '活動時間 ${list[idx]['activity_time']}',
                              style: const TextStyle(
                                  color: Color.fromARGB(180, 255, 255, 255)),
                            ),
                          ),
                          trailing: ElevatedButton(
                            child: const ImageIcon(deleteIcon),
                            onPressed: () => pushDelete(idx, context),
                            style: ElevatedButton.styleFrom(
                                shadowColor: transparentColor,
                                backgroundColor: transparentColor,
                                minimumSize: const Size(30, 30)),
                          ),
                          onTap: () {
                            checkActivity(activityData: [list[idx]]);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                '目前無活動資料\n點右下角的按鈕新增一個活動吧',
                style: TextStyle(fontSize: 20),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Scaffold(
        backgroundColor: activityGreen,
        appBar: AppBar(
          backgroundColor: grassGreen,
          title: const Center(
              child: Text(
            '活動清單',
          )),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          actions: [
            ElevatedButton(
              child: const ImageIcon(addIcon),
              onPressed: () => Navigator.pushNamed(context, "/AddActivityPage"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: transparentColor,
                  shadowColor: transparentColor),
            )
          ],
        ),
        body: showAllActivities(),
      ),
    );
  }

  void checkActivity({required List<dynamic> activityData}) async {
    final uID = activityData[0]['uID'];
    final uidMemberDataReq = {'uID': uID};
    List uidMemberDataResponse =
        await APIService.selectUidMemberData(content: uidMemberDataReq);
    Navigator.pushNamed(context, '/ShowActivityData', arguments: {
      'activityData': activityData[0],
      'activityHostData': uidMemberDataResponse[0]
    });
  }
}
