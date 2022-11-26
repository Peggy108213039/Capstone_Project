import 'dart:io';
import 'package:intl/intl.dart';
import 'package:capstone_project/models/activity/activity_model.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:capstone_project/services/sqlite_helper.dart';

import 'package:capstone_project/models/login_model.dart';
import 'package:capstone_project/models/signup_model.dart';
import 'package:capstone_project/models/userInfo/selectInfo_model.dart';
import 'package:capstone_project/models/userInfo/updateInfo_model.dart';
import 'package:capstone_project/models/friend/insertFriend_model.dart';
import 'package:capstone_project/models/friend/inviteFriend_model.dart';
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
  static late String userPhone;
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
      String getUserPhone,
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
  String ip = "http://163.22.17.247:3000";
  static final FileProvider fileProvider = FileProvider();
  Future<bool> login(LoginRequestModel requestModel) async {
    String url =
        "$ip/api/login_member"; // 透過此行連線，/api/login_member 即 POST 對應的 API 路徑
    final response =
        await http.post(Uri.parse(url), body: requestModel.toJson());
    var tmpResponse = LoginResponseModel.fromJson(json.decode(response.body));
    if (tmpResponse.result != "LOGIN FAILED") {
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
      // 以此 uID 查詢好友列表
      //selectFriend(SelectFriendRequestModel(uID1: tmpResponse.uID.toString()));
      var userID = {'uID': tmpResponse.uID.toString()};
      await selectUserAllTrack(userID);
      // await selectAccountActivity(content: userID);
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
    String url = "$ip/api/signup_member";
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

  // FIXME1118：更新成功後作法
  // 返回 T/F => 提醒使用者重新登入以更新自己的資料
  Future<bool> updateUserInfo(UpdateInfoRequestModel requestModel) async {
    String url = "$ip/api/member/update_member";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse["result"] != "Fail to update member") {
        return true;
      } else {
        print("UPDATE USER INFO RESULT：${jsonResponse["result"]}");
        return false;
      }
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  // 查詢好友清單：以 uID 呼叫 API 查詢好友姓名，返回結果一一插入 sqflite - friend table
  Future<bool> selectUserInfo(SelectInfoRequestModel requestModel) async {
    String url = "$ip/api/member/select_uid_member";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      var jsonResponse = json.decode(response.body);
      print("MY FRIEND：$jsonResponse");
      await SqliteHelper.insert(tableName: "friend", insertData: jsonResponse);
      return true;
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  // 好友
  // UID2 accept my friend invitation, then call insertFriend
  Future<bool> insertFriend(InsertFriendRequestModel requestModel) async {
    String url = "$ip/api/friend/insert_friend";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse["result"] == "Insert success") {
        return true;
      } else {
        print("=====INSERT FRIEND RESULT = ${jsonResponse["result"]}=====");
        return false;
      }
    } else {
      var statusCode = response.statusCode;
      print("=====INSERT FRIEND API STATUS CODE = ($statusCode)=====");
      return false;
    }
  }

  // 送出好友邀請前先確認 UID1 & UID2 好友關係
  Future<bool> checkFriend(CheckFriendRequestModel requestModel) async {
    String url = "$ip/api/friend/check_friend";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse["result"] == "Send friend request") {
        return true;
      } else {
        return false;
      }
    } else {
      var statusCode = response.statusCode;
      print("CHECK FRIEND API STATUS CODE = ($statusCode)");
      return false;
    }
  }

  // 送出好友邀請前先確認 UID1 & UID2 好友關係
  Future<bool> inviteFriend(InviteFriendRequestModel requestModel) async {
    String url = "$ip/api/friend/invite_friend";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse["result"] == "Invite success") {
        return true;
      } else {
        return false;
      }
    } else {
      var statusCode = response.statusCode;
      print("INVITE FRIEND API STATUS CODE = ($statusCode)");
      return false;
    }
  }

  Future<bool> deleleFriend(DeleteFriendRequestModel requestModel) async {
    String url = "$ip/api/friend/delete_friend";

    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse["result"] == "Delete success") {
        return true;
      } else {
        return false;
      }
    } else {
      var statusCode = response.statusCode;
      print("DELETE FRIEND API STATUS CODE = ($statusCode)");
      return false;
    }
  }

  // 列出好友清單
  Future<bool> selectFriend(SelectFriendRequestModel requestModel) async {
    await SqliteHelper.clear(tableName: "friend");
    String url = "$ip/api/friend/select_friend";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      List jsonResponse = json.decode(response.body); //回傳一個 Map
      print('FRIEND LIST FROM SERVER');
      for (var tmpResponse in jsonResponse) {
        // 使用 uID2 查詢 userInfo 以列出好友清單
        await selectUserInfo(
            SelectInfoRequestModel(uid: tmpResponse['uID2'].toString()));
      }
      print("我的朋友 table");
      print(await SqliteHelper.queryAll(tableName: "friend"));
      return true;
    } else {
      print(response.body);
      print("將好友們加入 sqlite 失敗");
      return false;
    }
  }

  static Future<List> addActivity(
      {required Map<String, dynamic> content}) async {
    String url = "http://163.22.17.247:3000/api/activity/insert_activity";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      return [true, responseString];
    } else {
      print(responseString);
      return [false, responseString];
    }
  }

  static Future<List> deleteActivity(
      {required Map<String, dynamic> content}) async {
    String url = "http://163.22.17.247:3000/api/activity/delete_activity";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      print('刪除活動 $responseString');
      return [true, responseString];
    } else {
      print(responseString);
      return [false, responseString];
    }
  }

  static Future<List> startActivity(
      {required Map<String, dynamic> content}) async {
    String url = "http://163.22.17.247:3000/api/activity/start_activity";

    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      return [true, responseString];
    } else {
      print('開始活動失敗');
      print(responseString);
      return [false, responseString];
    }
  }

  static Future<List> finishActivity(
      {required Map<String, dynamic> content}) async {
    String url = "http://163.22.17.247:3000/api/activity/finish_activity";

    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      print('結束活動成功');
      print(responseString);
      return [true, responseString];
    } else {
      print('結束活動失敗');
      print(responseString);
      return [false, responseString];
    }
  }

  static Future<List> updateActivity(
      {required Map<String, dynamic> content}) async {
    String url = "http://163.22.17.247:3000/api/activity/update_activity";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      print('更新活動 $responseString');
      return [true, responseString];
    } else {
      print(responseString);
      return [false, responseString];
    }
  }

  // 抓某使用者 (uID) 的活動資料
  static Future<void> selectAccountActivity(
      {required Map<String, dynamic> content}) async {
    print('刷新 sqlite 活動資料表');
    String url =
        "http://163.22.17.247:3000/api/activity/select_account_activity";
    await SqliteHelper.clear(tableName: "activity").then((value) async {
      // final response =
      await http
          .post(Uri.parse(url),
              headers: {'cookie': UserData.token}, body: content)
          .then((response) async {
        final serverActivities = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 400) {
          // 抓 sqlite 所有軌跡的 tID
          // List sqliteTidList =
          await SqliteHelper.queryAllTrackDataList(columns: ['tID'])
              .then((sqliteTidList) async {
            print('server 活動 長度 ${serverActivities.length}');
            List<String> hasDownloadTrackList = []; // 檢查是否已下載過
            for (var activity in serverActivities) {
              // 把 server 活動資料加進 sqlite
              final Activity newLocalActivityData = Activity(
                  aID: activity['aID'].toString(),
                  uID: activity['uID'].toString(),
                  activity_name: activity['activity_name'].toString(),
                  activity_time: activity['activity_time'].toString(),
                  start_activity_time:
                      activity['start_activity_time'].toString(),
                  finish_activity_time:
                      activity['finish_activity_time'].toString(),
                  tID: activity['tID'].toString(),
                  warning_distance: activity['warning_distance'].toString(),
                  warning_time: activity['warning_time'].toString(),
                  members: '');
              await SqliteHelper.insert(
                      tableName: 'activity',
                      insertData: newLocalActivityData.toMap())
                  .then((value) async {
                // 如果 sqliteTrackTidList 沒有活動的 tid 就下載該軌跡
                bool trackIsDownloaded = false;
                final String serverActivityTid = activity['tID'].toString();
                for (var tID in sqliteTidList) {
                  if (tID['tID'].toString() == serverActivityTid) {
                    trackIsDownloaded = true;
                    break;
                  }
                }
                // 如果已經下載過，就不用重複下載
                if (hasDownloadTrackList.contains(serverActivityTid)) {
                  trackIsDownloaded = true;
                }
                if (!trackIsDownloaded) {
                  // 下載該軌跡
                  Map<String, dynamic> specificTrack = {
                    'tID': serverActivityTid
                  };
                  List specificTrackResponse =
                      await selectSpecificTrackAndDownload(
                          content: specificTrack);
                  hasDownloadTrackList.add(serverActivityTid);
                  print(specificTrackResponse);
                }
              });
            }
            print('完成 刷新 sqlite 活動資料表');
            return [serverActivities];
          });
        } else {
          print('失敗 刷新 sqlite 活動資料表');
          print(
              '失敗 $serverActivities response.statusCode ${response.statusCode}');
          return [serverActivities];
        }
      });
    });
  }

  // 抓某使用者 (uID) 的相關資料
  static Future<List> selectUidMemberData(
      {required Map<String, dynamic> content}) async {
    String url = "http://163.22.17.247:3000/api/member/select_uid_member";
    print(content);
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      return [responseString];
    } else {
      print('失敗 $responseString response.statusCode ${response.statusCode}');
      return [responseString];
    }
  }

  // 抓 tID 的軌跡資料並下載
  static Future<List> selectSpecificTrackAndDownload(
      {required Map<String, dynamic> content}) async {
    String url = "http://163.22.17.247:3000/api/track/select_specific_track";
    // 抓軌跡資料夾的路徑
    await fileProvider.getAppPath;
    Directory? trackDir =
        await fileProvider.getSpecificDir(dirName: 'trackData');

    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final serverTrack = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      // 下載軌跡
      String savePath = '${trackDir!.path}/${serverTrack['track_name']}';
      // download server track file
      Map<String, dynamic> downloadTrackID = {'tid': serverTrack['tID']};
      List downloadTrackResult =
          await downloadTrack(savePath: savePath, content: downloadTrackID);
      print('下載成功   ${downloadTrackResult[0]}');
      // 更新 sqlite
      if (downloadTrackResult[0]) {
        Track newClientTrackData = Track(
            tID: serverTrack['tID'].toString(),
            uID: serverTrack['uID'].toString(),
            track_name: serverTrack['track_name'],
            track_locate: savePath,
            start: serverTrack['start'],
            finish: serverTrack['finish'],
            total_distance: serverTrack['total_distance'].toString(),
            time: serverTrack['time'],
            track_type: '2'); // 活動軌跡
        List insertClientTrackResult = await SqliteHelper.insert(
            tableName: 'track', insertData: newClientTrackData.toMap());
        if (insertClientTrackResult[0]) {
          print('本機端新增軌跡 ${serverTrack['tID']} 成功');
        } else {
          print('本機端新增軌跡 ${serverTrack['tID']} 失敗');
        }
      } else {
        print("err.message:  ${downloadTrackResult[1]}");
        print('server 下載軌跡 ${serverTrack['tID']} 失敗');
      }
      return [true, serverTrack];
    } else {
      print('失敗 $serverTrack response.statusCode ${response.statusCode}');
      return [false, []];
    }
  }

  // 抓某使用者的所有軌跡的資料
  static Future<List> selectUserAllTrack(Map<String, dynamic> content) async {
    String url = "http://163.22.17.247:3000/api/track/select_track";
    await SqliteHelper.clear(tableName: "track");

    // 抓軌跡資料夾的路徑
    await fileProvider.getAppPath;
    Directory? trackDir =
        await fileProvider.getSpecificDir(dirName: 'trackData');
    fileProvider.deleteDirectory(directory: trackDir!);
    trackDir = await fileProvider.getSpecificDir(dirName: 'trackData');
    print('==========\ntrackDir ${trackDir!.path}\n==========');

    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final serverTracks = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      // print(serverTracks);
      for (var _track in serverTracks) {
        print('_track $_track');
        // 將 sqlite 軌跡的資料更新成跟 server 一樣
        // 下載軌跡
        String savePath = '${trackDir.path}/${_track['track_name']}';
        // download server track file
        Map<String, dynamic> downloadTrackID = {'tid': _track['tID']};
        List downloadTrackResult =
            await downloadTrack(savePath: savePath, content: downloadTrackID);
        print('下載成功   ${downloadTrackResult[0]}');
        // 更新 sqlite
        if (downloadTrackResult[0]) {
          Track newClientTrackData = Track(
              tID: _track['tID'].toString(),
              uID: _track['uID'].toString(),
              track_name: _track['track_name'],
              track_locate: savePath,
              start: _track['start'],
              finish: _track['finish'],
              total_distance: _track['total_distance'].toString(),
              time: _track['time'],
              track_type: _track['track_type'].toString());
          List insertClientTrackResult = await SqliteHelper.insert(
              tableName: 'track', insertData: newClientTrackData.toMap());
          if (insertClientTrackResult[0]) {
            _track['isDownloaded'] = true;
            print('本機端新增軌跡 ${_track['tID']} 成功');
          } else {
            print('本機端新增軌跡 ${_track['tID']} 失敗');
          }
        } else {
          print("err.message:  ${downloadTrackResult[1]}");
          print('server 下載軌跡 ${_track['tID']} 失敗');
        }
      }
      return [true, serverTracks];
    } else {
      print('失敗 $serverTracks response.statusCode ${response.statusCode}');
      return [false, []];
    }
  }

  // 新增軌跡，回傳 bool
  static Future<List> insertTrack(TrackRequestModel requestModel) async {
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
        contentType: MediaType('trackFile', 'gpx'),
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
  static Future<List> deleteTrack(Map<String, dynamic> content) async {
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
    } else {
      deleteSuccess = false;
      print(response.body);
    }
    return [deleteSuccess, responseString];
  }

  // 刪除軌跡，回傳 bool
  static Future<List> downloadTrack(
      {required String savePath, required Map<String, dynamic> content}) async {
    bool downloadSuccess = false;
    String url = "http://163.22.17.247:3000/api/track/download_track";
    try {
      final Response response = await Dio().download(url, savePath,
          queryParameters: content,
          options: Options(headers: {'cookie': UserData.token}));
      downloadSuccess = true;
      return [downloadSuccess, savePath];
    } on DioError catch (err) {
      print(err.message);
      downloadSuccess = false;
      return [downloadSuccess, err.message];
    }
  }

  // 修改軌跡名稱
  static Future<List> updateTrackName(
      {required Map<String, dynamic> content}) async {
    String url = "http://163.22.17.247:3000/api/track/update_track";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      return [true, responseString];
    } else {
      print('失敗 $responseString response.statusCode ${response.statusCode}');
      return [false, responseString];
    }
  }

  // 更新使用者累積距離 & 時間
  static Future<List> updateDistanceTimeMember(
      {required Map<String, dynamic> content}) async {
    String url =
        "http://163.22.17.247:3000/api/member/update_distance_time_member";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      return [true, responseString];
    } else {
      print('失敗 $responseString response.statusCode ${response.statusCode}');
      return [false, responseString];
    }
  }

  // 更新使用者累積軌跡數
  static Future<List> updateTrackMember(
      {required Map<String, dynamic> content}) async {
    String url = "http://163.22.17.247:3000/api/member/update_track_member";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      return [true, responseString];
    } else {
      print('失敗 $responseString response.statusCode ${response.statusCode}');
      return [false, responseString];
    }
  }

  // 更新使用者累積活動數
  static Future<List> updateActivityMember(
      {required Map<String, dynamic> content}) async {
    String url = "http://163.22.17.247:3000/api/member/update_activity_member";
    final response = await http.post(Uri.parse(url),
        headers: {'cookie': UserData.token}, body: content);
    final responseString = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 400) {
      return [true, responseString];
    } else {
      print('失敗 $responseString response.statusCode ${response.statusCode}');
      return [false, responseString];
    }
  }
}
