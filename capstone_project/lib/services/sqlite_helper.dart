import 'package:sqflite/sqflite.dart';

class SqliteHelper {
  static const sqlFileName = 'mountain.db'; // Sqlite 的檔案名稱 (類似資料庫的名稱)
  static const int dbVersion = 1;
  static const trackTable = 'track'; // 資料表的名稱
  static const activTable = 'activity';
  static const offlineMapTable = 'offlineMap';
  static const friendTable = 'friend';
  static const notificationTable = 'notification';

  // only have a single app-wide reference to the database
  static Database? db;
  static Future<Database?> get open async => db ??= await initDatabase();

  static Future<Database?> initDatabase() async {
    print('初始化資料庫');
    String path =
        "${await getDatabasesPath()}/$sqlFileName"; // 這是 Future 的資料，前面要加 await
    print('DB PATH $path');

    db = await openDatabase(path, version: dbVersion, onCreate: _onCreate);
    print('DB DB $db');
    return db;
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 軌跡
    await db.execute('''
        CREATE TABLE $trackTable (
        tID text,
        uID text,
        track_name text,
        track_locate text,
        start text,
        finish text,
        total_distance text,
        time text,
        track_type text
        );
      ''');
    print('建立軌跡資料表');
    // 活動
    await db.execute('''
        CREATE TABLE $activTable (
        aID text,
        uID text,
        activity_name text,
        activity_time text,
        start_activity_time text,
        finish_activity_time text,
        tID text,
        warning_distance text,
        warning_time text,
        members text
        );
      ''');
    print('建立活動資料表');
    // 離線地圖
    await db.execute('''
        CREATE TABLE $offlineMapTable (
        offline_map_ID integer primary key AUTOINCREMENT,
        uID text,
        offline_map_name text,
        centerLatitude text,
        centerLongitude text,
        southWestLatitude text,
        southWestLongitude text,
        northEastLatitude text,
        northEastLongitude text,
        png_dir_locate text
        );
      ''');
    print('建立離線地圖資料表');
    // 建立 userinfo table
    await db.execute('''
        CREATE TABLE $friendTable (
        fID integer primary key AUTOINCREMENT,
        uID integer,
        account text,
        name text
        );
      ''');
    print('建立好友資料表');
    await db.execute('''
        CREATE TABLE $notificationTable (
        nID integer primary key AUTOINCREMENT,
        ctlmsg text,
        account_msg text,
        friend_msg text,
        activity_msg text,
        info text
        );
      ''');
    print('建立我的通知資料表');
  }

  // 新增
  static Future<List> insert(
      {required String tableName,
      required Map<String, dynamic> insertData}) async {
    final Database? database = await open;
    try {
      int? result = await database?.insert(tableName, insertData,
          conflictAlgorithm: ConflictAlgorithm.replace);
      result ??= 0;
      return [true, result];
    } catch (err) {
      print('DbException' + err.toString());
      return [false, -1];
    }
  }

  // 抓所有資料
  static Future<List<Map<String, dynamic>>?> queryAll(
      {required String tableName}) async {
    final Database? database = await open;
    var result = await database?.query(tableName, columns: null);
    result ??= [];
    return result;
  }

  // 抓所有軌跡的資料
  static Future<List<Map<String, dynamic>>> queryAllTrackDataList(
      {required List<String> columns}) async {
    final Database? database = await open;
    var result = await database?.query('track', columns: columns);
    result ??= [];
    return result;
  }

  // 抓特定資料
  static Future<List<Map<String, dynamic>>?> queryRow(
      {required String tableName,
      required String key,
      required String value}) async {
    final Database? database = await open;
    var sql = 'SELECT * FROM $tableName WHERE $key=?';
    return await database?.rawQuery(sql, [value]);
  }

  // 編輯
  static Future<void> update(
      {required String tableName,
      required Map<String, dynamic> updateData,
      required String tableIdName,
      required int updateID}) async {
    final Database? database = await open;
    await database?.update(tableName, updateData,
        where: '$tableIdName = ?', whereArgs: [updateID]);
  }

  // 刪除
  static Future<int?> delete(
      {required String tableName,
      required String tableIdName,
      required int deleteId}) async {
    final Database? database = await open;
    return await database?.delete(tableName, where: '$tableIdName=$deleteId');
  }

  // 清空資料表
  static Future<void> clear({
    required String tableName,
  }) async {
    final Database? database = await open;
    print("以清空 $tableName 資料表");
    return await database?.execute('DELETE FROM `$tableName`;');
  }

  // drop table
  static Future<void> drop({
    required String tableName,
  }) async {
    final Database? database = await open;
    print("已 drop $tableName 資料表");
    return await database?.execute('DROP TABLE `$tableName`;');
  }
}
