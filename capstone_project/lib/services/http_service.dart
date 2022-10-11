import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:capstone_project/services/sqlite_helper.dart';

import 'package:capstone_project/models/login_model.dart';
import 'package:capstone_project/models/signup_model.dart';
import 'package:capstone_project/models/userInfo/selectInfo_model.dart';
import 'package:capstone_project/models/userInfo/updateInfo_model.dart';
import 'package:capstone_project/models/activity/addActivity_model.dart';
import 'package:capstone_project/models/activity/finishActivity_model.dart';
import 'package:capstone_project/models/activity/startActivity_model.dart';
import 'package:capstone_project/models/friend/addFriend_model.dart';
import 'package:capstone_project/models/friend/selectFriend_model.dart';
import 'package:capstone_project/models/friend/deleteFriend_model.dart';
import 'package:capstone_project/models/friend/checkFriend_model.dart';
import 'package:capstone_project/models/track/track_model.dart';

class UserData {
  // 存放使用者資料
  static late String token;
  static late int uid;
  static late String userAccount;
  static late String userName;
  static late String password;
  static late String userEmail;
  static late int userPhone;
  static late int totalDistance;
  static late int totalTime;
  static late int totalActivity;
  static late int totalTrack;

  UserData(
      String getToken,
      int getUid,
      String getUserAccount,
      String getUserName,
      String getPassword,
      String getUserEmail,
      int getUserPhone,
      int getTotalDiatance,
      int getTotalTime,
      int getTotalActivity,
      int getTotalTrack) {
    token = getToken;
    uid = getUid;
    userAccount = getUserAccount;
    userName = getUserName;
    password = getPassword;
    userEmail = getUserEmail;
    userPhone = getUserPhone;
    totalDistance = getTotalDiatance;
    totalTime = getTotalTime;
    totalActivity = getTotalActivity;
    totalTrack = getTotalTrack;
  }
}

class APIService {
  Future<bool> login(LoginRequestModel requestModel) async {
    String url =
        "http://163.22.17.247:3000/api/login_member"; // 透過此行連線，/api/login_member 即 POST 對應的 API 路徑
    print('requestModel   ${requestModel.toJson()}');
    final response =
        await http.post(Uri.parse(url), body: requestModel.toJson());
    var tmpResponse = LoginResponseModel.fromJson(json.decode(response.body));
    if (tmpResponse.result != "Login fail") {
      UserData(
        response.headers['set-cookie']!,
        tmpResponse.uID,
        tmpResponse.account,
        tmpResponse.name,
        tmpResponse.password,
        tmpResponse.email,
        tmpResponse.phone,
        tmpResponse.totalDiatance,
        tmpResponse.totalTime,
        tmpResponse.totalActivity,
        tmpResponse.totalTrack,
      );
      print("登入成功");
      selectFriend(SelectFriendRequestModel(uID1: tmpResponse.uID.toString()));
      print('==========\n使用者 uID ${tmpResponse.uID}\n==========');
      //await FlutterSession().set("token", UserData.token);
      return true;
      // 如果 server 回傳 json 格式則應該像下行寫，才能把 server response 的 json 資料抓出來用
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print("登入失敗");
      print(tmpResponse.result);
      // return false;
      return false;
    }
  }

  Future<bool> signup(SignUpRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/signup_member";
    final response =
        await http.post(Uri.parse(url), body: requestModel.toJson());
    var tmpResponse = SignUpResponseModel.fromJson(json.decode(response.body));
    print("註冊RESPONSE $response");
    if ((response.statusCode == 200 || response.statusCode == 400) ||
        (tmpResponse.result == "create account")) {
      // UserData(
      //   response.headers['set-cookie']!,
      //   int.parse(tmpResponse.uID),
      //   tmpResponse.account,
      //   tmpResponse.name,
      //   tmpResponse.password,
      //   tmpResponse.email,
      //   int.parse(tmpResponse.phone),
      //   0,0,0,0,
      // );
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print("註冊失敗");
      print(tmpResponse.result);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  Future<bool> updateUserInfo(UpdateInfoRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      print(response.body);
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  // 查詢好友清單
  // 以 uID 呼叫 API 查詢
  // 返回結果一一插入 sqflite - friend table
  Future<bool> selectUserInfo(SelectInfoRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/member/select_uid_member";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      var jsonResponse = json.decode(response.body);
      print("JSON RESPONSE IN SELECTUSERINFO $jsonResponse");
      await SqliteHelper.insert(tableName: "friend", insertData: jsonResponse);
      // for (var tmpResponse in jsonResponse){
      //   print(jsonResponse);
      //   await SqliteHelper.insert(tableName: "friend", insertData: tmpResponse);
      // }
      return true;
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  // 好友
  // UID2 accept my friend invitation, then call insertFriend
  Future<bool> addFriend(AddFriendRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/friend/insert_friend";

    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      print(response.body);
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  // 確認 UID1 & UID2 好友關係
  Future<bool> checkFriend(CheckFriendRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/friend/check_friend";

    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      print(response.body);
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  Future<bool> deleleFriend(DeleteFriendRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/friend/delete_friend";

    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      print(response.body);
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  // 列出好友清單
  Future<bool> selectFriend(SelectFriendRequestModel requestModel) async {
    await SqliteHelper.clear(tableName: "friend");
    String url = "http://163.22.17.247:3000/api/friend/select_friend";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    SelectInfoRequestModel selectInfoRequestModel;
    selectInfoRequestModel = SelectInfoRequestModel(uid: "");
    if (response.statusCode == 200 || response.statusCode == 400) {
      List jsonResponse = json.decode(response.body); //回傳一個 Map
      for (var tmpResponse in jsonResponse) {
        // 使用 uID2 查詢 userInfo 以列出好友清單
        print(tmpResponse);
        selectInfoRequestModel.uid = tmpResponse["uID2"].toString();
        await selectUserInfo(selectInfoRequestModel);
      }
      print("我的朋友 table");
      print(await SqliteHelper.queryAll(tableName: "friend"));
      return true;
    } else {
      print(response.body);
      print("將好友們加入 sqlite 失敗");
      return false;
      throw Exception("Failed to Load Data");
    }
  }

  // 活動
  Future<bool> addActivity(AddActivityRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/activity/insert_activity";

    final response =
        await http.post(Uri.parse(url), body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      print(response.body);
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  Future<bool> startActivity(StartActivityRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/activity/start_activity";

    final response =
        await http.post(Uri.parse(url), body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      print(response.body);
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  Future<bool> finishActivity(FinishActivityRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/activity/start_activity";

    final response =
        await http.post(Uri.parse(url), body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      print(response.body);
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  // 抓某使用者的所有軌跡的資料
  static Future<bool> selectUserAllTrack(Map<String, dynamic> content) async {
    String url = "http://163.22.17.247:3000/api/track/select_track";
    print(content);
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    if (response.statusCode == 200 || response.statusCode == 400) {
      print(response.body);
      return true;
    } else {
      print('失敗 ${response.body} response.statusCode ${response.statusCode}');
      return false;
    }
  }

  // 新增軌跡，回傳 bool
  static Future<List> insertTrack(Track requestModel) async {
    String url = "http://163.22.17.247:3000/api/track/insert_track";

    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toMap());
    final responseString = jsonDecode(response.body);
    bool insertSussess = false;
    if (response.statusCode == 200 || response.statusCode == 400) {
      if (responseString['result'] == 'Fail to add track' ||
          responseString['result'] == 'Session fail') {
        insertSussess = false;
      } else {
        insertSussess = true;
      }
    } else {
      insertSussess = false;
      print(responseString);
    }
    return [insertSussess, responseString];
  }

  // 上傳軌跡
  static Future<List> uploadTrack(
      File trackFile, Map<String, String> content) async {
    final url = Uri.parse("http://163.22.17.247:3000/api/track/upload_track");
    var stream = http.ByteStream(trackFile.openRead());
    stream.cast();
    var length = await trackFile.length();
    var request = http.MultipartRequest("POST", url);
    request.fields.addAll(content);
    request.headers.addAll({'cookie': UserData.token});
    var multipartFile = http.MultipartFile('files', stream, length,
        filename: basename(trackFile.path));
    request.files.add(multipartFile);
    final response = await request.send();
    Map<String, dynamic> responseString =
        jsonDecode(await response.stream.bytesToString());
    bool uploadSuccess = false;

    if (response.statusCode == 200 || response.statusCode == 400) {
      if (responseString['result'] == "Fail to upload track" ||
          responseString['result'] == 'Session fail') {
        uploadSuccess = false;
      } else {
        uploadSuccess = true;
      }
      print('上傳軌跡 $responseString');
    } else {
      uploadSuccess = false;
      print(responseString);
    }
    return [uploadSuccess, responseString];
  }

  // 刪除軌跡，回傳 bool
  static Future<bool> deleteTrack(Map<String, dynamic> content) async {
    String url = "http://163.22.17.247:3000/api/track/delete_track";

    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    bool deleteSuccess = false;

    if (response.statusCode == 200 || response.statusCode == 400) {
      if (responseString['result'] == "Delete a track successfully") {
        deleteSuccess = true;
      } else {
        deleteSuccess = false;
      }
      print('刪除軌跡 $responseString');
    } else {
      deleteSuccess = false;
      print(response.body);
    }
    return deleteSuccess;
  }
}
