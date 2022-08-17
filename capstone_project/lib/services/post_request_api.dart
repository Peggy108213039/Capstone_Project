import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as my_http;

_post() async{
  var responseBody;
  //1.�إ�HttpClient
  var httpClient = new HttpClient();
  //2.�c�yUri
  var requset = await httpClient.postUrl(Uri.parse("163.22.17.247:3000"));
  //3.�����ШD�A�����T��
  var response = await requset.close();
  //4.�i��ѽX�A������
  if(response.statusCode == 200){
  //����ШD�����
  responseBody = await response.transform(utf8.decoder).join();
  //�����ѪR�C�L���
    print(responseBody);
  }else{
    print("error");
  }
}

//http�w��post�ШD�覡
http_post() async{
  try{
    //�]���פJhttp �ΤFas xxx�覡�A�ҥH����ШD����xxx.get�覡
    var response = await my_http.post(Uri.parse("163.22.17.247:3000"));
    if(response.statusCode == 200){
      //�C�L��^�����
      print(response.body);
    }else{
      print("error");
    }
  }catch(e){
    print(e);
  }
}