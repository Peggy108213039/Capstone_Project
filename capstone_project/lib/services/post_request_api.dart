import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as my_http;

_post() async{
  var responseBody;
  //1.建立HttpClient
  var httpClient = new HttpClient();
  //2.構造Uri
  var requset = await httpClient.postUrl(Uri.parse("163.22.17.247:3000"));
  //3.關閉請求，等待響應
  var response = await requset.close();
  //4.進行解碼，獲取資料
  if(response.statusCode == 200){
  //拿到請求的資料
  responseBody = await response.transform(utf8.decoder).join();
  //先不解析列印資料
    print(responseBody);
  }else{
    print("error");
  }
}

//http庫的post請求方式
http_post() async{
  try{
    //因為匯入http 用了as xxx方式，所以物件請求都用xxx.get方式
    var response = await my_http.post(Uri.parse("163.22.17.247:3000"));
    if(response.statusCode == 200){
      //列印返回的資料
      print(response.body);
    }else{
      print("error");
    }
  }catch(e){
    print(e);
  }
}