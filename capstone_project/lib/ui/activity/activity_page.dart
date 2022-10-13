import 'package:capstone_project/constants.dart';
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

  void pushBack() {
    setState(() {
      _visible = false;
    });
  }

  void pushEdit() {
    // FIXME：除了刪除和返回，其他按鈕不能按
    showDeleteBtn();
  }

  void showDeleteBtn() {
    setState(() {
      _visible = true;
    });
  }

  pushDelete(int idx, BuildContext context) async {
    final deleteActiv = activTable![idx];
    final String deleteActivName = deleteActiv['activity_name'];
    final int deleteAID = deleteActiv['aID'];
    bool? toDelete = await _showAlertDialog(
        context: context,
        myTitle: '刪除軌跡',
        myContent: '確定要刪除活動 $deleteActivName ?',
        btn1Text: '刪除',
        btn2Text: '取消');
    toDelete ??= false;
    print('是否要刪除軌跡 $toDelete 活動 $deleteAID');
    if (toDelete) {
      var result = await SqliteHelper.delete(
          tableName: 'activity', tableIdName: 'aID', deleteId: deleteAID);
      activTable = await SqliteHelper.queryAll(tableName: 'activity');
      setState(() {
        print('刪除軌跡完成');
      });
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
                    ListTile(
                      title: Text(
                        list[idx]['activity_name'],
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          '活動時間 ${list[idx]['activity_time']}',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ),
                      trailing: Visibility(
                        visible: _visible,
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          // 刪除活動
                          onPressed: () => pushDelete(idx, context),
                          color: Colors.grey.shade400,
                          tooltip: '刪除軌跡',
                        ),
                      ),
                      onTap: () {
                        checkActivity(activityData: [list[idx]]);
                      },
                    ),
                    const Divider(
                      height: 10.0,
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
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: defaultBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: transparentColor,
        appBar: AppBar(
          backgroundColor: transparentColor,
          title: const Center(
              child: Text(
            '活動清單',
          )),
          leading: Visibility(
            visible: _visible,
            child: IconButton(
              onPressed: pushBack,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: '返回',
            ),
          ),
          actions: [
            IconButton(
              onPressed: pushEdit,
              icon: const Icon(Icons.edit),
              tooltip: '編輯活動',
            )
          ],
        ),
        body: showAllActivities(),
        floatingActionButton: FloatingActionButton(
          tooltip: '新增活動',
          foregroundColor: Colors.white,
          backgroundColor: Colors.indigoAccent.shade100,
          child: const Icon(
            Icons.add,
            size: 35.0,
          ),
          onPressed: () {
            print('匯入軌跡');
            Navigator.pushNamed(context, "/AddActivityPage");
          },
        ),
      ),
    );
  }

  void checkActivity({required List<dynamic> activityData}) {
    print('查看活動 $activityData');
    print('aID  ${activityData[0]['aID']}');
    Navigator.pushNamed(context, '/ShowActivityData',
        arguments: activityData[0]);
  }
}
