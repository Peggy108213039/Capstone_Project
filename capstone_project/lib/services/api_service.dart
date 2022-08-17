import 'package:http/http.dart' as http;
import 'package:capstone_project/models/activity/addActivity_model.dart';
import 'package:capstone_project/models/friend/addFriend_model.dart';
import 'package:capstone_project/models/friend/checkFriend_model.dart';
import 'package:capstone_project/models/friend/delFriend_model.dart';
import 'package:capstone_project/models/activity/finishActivity_model.dart';
import 'dart:convert';

import 'package:capstone_project/models/login_model.dart';
import 'package:capstone_project/models/friend/selectFriend_model.dart';
import 'package:capstone_project/models/signup_model.dart';
import 'package:capstone_project/models/activity/startActivity_model.dart';
 
class APIService {
  Future<bool> login(LoginRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/login_member";

    final response = await http.post(Uri.parse(url), body: requestModel.toJson());
    // if server return login successful
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
  Future<bool> signup(SignUpRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/signup_member";

    final response = await http.post(Uri.parse(url), body: requestModel.toJson());
    if(response.statusCode == 200 || response.statusCode == 400){
      print(response.body);
      if (response.body.toString() == "create account"){
        print("signup succesful");
      }
      return true;
      // return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      return false;
      // throw Exception("Failed to Load Data");
    }
  }

  // Friend
  // UID2 accept my friend invitation, then call insertFriend
  Future<bool> addFriend(AddFriendRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/friend/insert_friend";

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
  // check if UID1 & UID2 is friend already
  Future<bool> checkFriend(CheckFriendRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/friend/check_friend";

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
  Future<bool> deleleFriend(DeleteFriendRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/friend/delete_friend";

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
  // list Friend list
  Future<SelectFriendResponseModel> selectFriend(SelectFriendRequestModel requestModel) async {
    String url = "http://163.22.17.247:3000/api/friend/select_friend";

    final response = await http.post(Uri.parse(url), body: requestModel.toJson());
    if(response.statusCode == 200 || response.statusCode == 400){
      print(response.body);
      // return true;
      return SelectFriendResponseModel.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      // return false;
      throw Exception("Failed to Load Data");
    }
  }

  // Activity
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
