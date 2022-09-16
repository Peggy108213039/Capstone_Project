import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:capstone_project/models/login_model.dart';
import 'package:capstone_project/models/signup_model.dart';
import 'package:capstone_project/models/updateInfo_model.dart';
import 'package:capstone_project/models/activity/addActivity_model.dart';
import 'package:capstone_project/models/activity/finishActivity_model.dart';
import 'package:capstone_project/models/activity/startActivity_model.dart';
import 'package:capstone_project/models/friend/addFriend_model.dart';
import 'package:capstone_project/models/friend/selectFriend_model.dart';
import 'package:capstone_project/models/friend/deleteFriend_model.dart';
import 'package:capstone_project/models/friend/checkFriend_model.dart';

class UserData { // 存放使用者資料
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
    int getTotalTrack){
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
    String url = "http://163.22.17.247:3000/api/login_member"; // 透過此行連線，/api/login_member 即 POST 對應的 API 路徑
    final response = await http.post(Uri.parse(url),body: requestModel.toJson());
    var tmpResponse = LoginResponseModel.fromJson(json.decode(response.body));
    if (tmpResponse.result != "Login fail"){
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
      //await FlutterSession().set("token", UserData.token);
      //print(response.headers['set-cookie']);
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
    final response = await http.post(Uri.parse(url), body: requestModel.toJson());
    var tmpResponse = SignUpResponseModel.fromJson(json.decode(response.body));
    if((response.statusCode == 200 || response.statusCode == 400) && (tmpResponse.result == "create account")){
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
      print("註冊成功");
      print(response.body);
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print("註冊失敗");
      print(tmpResponse.result);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }
  
  // FIXME 0912 : update User info
  Future<bool> updateUserInfo(UpdateInfoRequestModel requestModel) async{
    String url = "http://163.22.17.247:3000";

    final response = await http.post(Uri.parse(url),headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if(response.statusCode == 200 || response.statusCode == 400){
      print(response.body);
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
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

    final response = await http.post(Uri.parse(url),headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if(response.statusCode == 200 || response.statusCode == 400){
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

    final response = await http.post(Uri.parse(url),headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if(response.statusCode == 200 || response.statusCode == 400){
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

    final response = await http.post(Uri.parse(url),headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if(response.statusCode == 200 || response.statusCode == 400){
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
  Future<SelectFriendResponseModel> selectFriend(SelectFriendRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/friend/select_friend";
    final response = await http.post(Uri.parse(url),headers: {'cookie': UserData.token}, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400){
      print("【我的朋友們】");
      print(response.body);
      // return true;
      return SelectFriendResponseModel.fromJson(json.decode(response.body));
    } else{
      print(response.body);
      // return false;
      throw Exception("Failed to Load Data");
    }
  }

  // 活動
  Future<bool> addActivity(AddActivityRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/activity/insert_activity";

    final response = await http.post(Uri.parse(url), body: requestModel.toJson());
    if(response.statusCode == 200 || response.statusCode == 400){
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

    final response = await http.post(Uri.parse(url), body: requestModel.toJson());
    if(response.statusCode == 200 || response.statusCode == 400){
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

    final response = await http.post(Uri.parse(url), body: requestModel.toJson());
    if(response.statusCode == 200 || response.statusCode == 400){
      print(response.body);
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }
}