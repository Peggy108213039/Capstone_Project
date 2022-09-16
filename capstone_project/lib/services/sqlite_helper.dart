import 'package:sqflite/sqflite.dart';

class SqliteHelper {
  static const sqlFileName = 'mountain.db'; // Sqlite 的檔案名稱 (類似資料庫的名稱)
  static const int dbVersion = 1;
  static const trackTable = 'track'; // 資料表的名稱
  static const activTable = 'activity';
  static const userTable = 'userinfo';

  // only have a single app-wide reference to the database
  static Database? db;
  static Future<Database?> get open async => db ??= await initDatabase();

  static Future<Database?> initDatabase() async {
    print('初始化資料庫');
    // 會根據 iOS/Android 分別給我們 Documents/Storage Path
    // getDatabasesPath()：會找出目前 APP 檔案的位置 (路徑)、android external storage 的位置
    String path =
        "${await getDatabasesPath()}/$sqlFileName"; // 這是 Future 的資料，前面要加 await
    print('DB PATH $path');

    // onCreate：後面接的是一個 function，產生一個資料表 (table)
    // ??= 判斷 db (左側) 是不是 null，如果是的話就設定 db 為右側的值
    db = await openDatabase(path, version: dbVersion, onCreate: _onCreate);
    print('DB DB $db');
    return db;
    // return await openDatabase(path, version: dbVersion, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // exexute：代表後面接的是一個 sql 語法
    // ''' 三個點代表可以讓字串有很多行
    // 資料表名稱為 post
    // 建立軌跡資料庫
    await db.execute('''
        CREATE TABLE $trackTable (
        tID integer primary key AUTOINCREMENT,
        uID interger,
        track_name text,
        track_locate text,
        start text,
        finish text,
        total_distance text,
        time text,
        track_type text
        );
      ''');
    print('建立軌跡資料庫');
    await db.execute('''
        CREATE TABLE $activTable (
        aID integer primary key AUTOINCREMENT,
        uID interger,
        activity_name text,
        activity_time text,
        tID text,
        warning_distance text,
        warning_time text
        );
      ''');
    print('建立活動資料庫');
    // 建立 userinfo table
    await db.execute('''
        CREATE TABLE $userTable (
        uID interger primary key,
        user_name text,
        user_account text,
        user_password text,
        user_email text,
        user_phone int
        );
      ''');
    print('建立使用者資訊資料表');
  }

  // 新增
  static Future<void> insert(
      {required String tableName,
      required Map<String, dynamic> insertData}) async {
    final Database? database = await open;
    try {
      await database?.insert(tableName, insertData,
          conflictAlgorithm: ConflictAlgorithm.replace);
      print('資料已寫入');
    } catch (err) {
      print('DbException' + err.toString());
    }
  }

  // 抓所有資料
  static Future<List<Map<String, dynamic>>?> queryAll(
      {required String tableName}) async {
    final Database? database = await open;
    // (資料表, 要查詢的東西)
    // 如果是 null，代表會回傳所有的東西
    var result = await database?.query(tableName, columns: null);
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
}