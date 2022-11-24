// import 'package:my_capstone_project/ui/notification_page.dart';
// import 'package:my_capstone_project/ui/login_page.dart';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:capstone_project/components/infoBox.dart';
import 'package:capstone_project/components/loadingAnimation.dart';
// basic
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/default_buttons.dart';
import 'package:capstone_project/components/default_icons.dart';
import 'package:capstone_project/models/userInfo/updateInfo_model.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/services/stream_socket.dart';
import 'package:capstone_project/size_config.dart';
import 'package:capstone_project/ui/setting/aboutUs_page.dart';
import 'package:capstone_project/ui/setting/assistance_page.dart';
import 'package:capstone_project/ui/setting/updateMyPwd_page.dart';
// ui setting
import 'package:capstone_project/ui/login_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  GlobalKey<FormState> globalFormKeyofEmail = GlobalKey<FormState>();
  GlobalKey<FormState> globalFormKeyofPhone = GlobalKey<FormState>();
  late UpdateInfoRequestModel requestModel;
  bool isApiCallProcess = false;

  String userName = UserData.userName;
  String userAccount = UserData.userAccount;
  String userEmail = UserData.userEmail;
  String userPhone = UserData.userPhone;

  @override
  void initState() {
    super.initState();
    requestModel = UpdateInfoRequestModel(
        uid: UserData.uid,
        name: '',
        password: '',
        email: '',
        phone: '0');
  }

  @override
  Widget build(BuildContext context) {
    return LoadingAnimation(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
    );
  }

  Widget _uiSetup(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: defaultBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.noteBarHeight!,
              left: getProportionateScreenWidth(0.03),
              right: getProportionateScreenWidth(0.03),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    DefNotificationIcon(enable: true),
                    DefSettingIcon(enable: false,),
                  ],
                ),
                Container(
                  // person info bar
                  decoration: BoxDecoration(
                      border: Border.all(color: darkGreen1, width: 3)),
                  height: getProportionateScreenHeight(0.15),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double innerHeight = constraints.maxHeight;
                      double innerWidth = constraints.maxWidth;
                      return InfoBox(
                        innerHeight: innerHeight,
                        innerWidth: innerWidth,
                        visible: true,
                      );
                    },
                  ),
                ),
                const VerticalSpacing(percent: 0.01),
                Container(
                  height: getProportionateScreenHeight(0.57),
                  width: getProportionateScreenWidth(0.9),
                  decoration: BoxDecoration(
                    //border: Border.all(color: Color.fromARGB(255, 255, 255, 255), width: 3),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 5),
                      child: Column(
                        children: [
                          const VerticalSpacing(percent: 0.01),
                          const Text(
                            '基本資料',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkGreen2,
                              fontSize: 22,
                            ),
                          ),
                          const VerticalSpacing(percent: 0.02),
                          GestureDetector(
                            // modify Email
                            onTap: () {
                              modifyEmailAlert(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: darkGreen1, width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              height:
                                  getProportionateScreenHeight(0.08), //0.15*0.5
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(7),
                              child: Text(
                                '信箱 ：' + userEmail,
                                style: const TextStyle(
                                    color: darkGreen2, fontSize: 18),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              modifyPhoneAlert(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: darkGreen1, width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              height:
                                  getProportionateScreenHeight(0.08), //0.15*0.5
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(7),
                              child: Text(
                                '電話號碼 ：' + userPhone.toString(),
                                style: const TextStyle(
                                    color: darkGreen2, fontSize: 18),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UpdatePwdPage(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: darkGreen1, width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              height:
                                  getProportionateScreenHeight(0.08), //0.15*0.5
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(7),
                              child: const Text(
                                '重設密碼',
                                style:
                                    TextStyle(color: darkGreen2, fontSize: 18),
                              ),
                            ),
                          ),
                          const VerticalSpacing(
                            percent: 0.02,
                          ),
                          const Text(
                            '其他',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkGreen2,
                              fontSize: 22,
                            ),
                          ),
                          const VerticalSpacing(
                            percent: 0.01,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AssistancePage(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: darkGreen2, width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              height:
                                  getProportionateScreenHeight(0.08), //0.15*0.5
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(7),
                              child: const Text(
                                '協助工具',
                                style:
                                    TextStyle(color: lightGreen1, fontSize: 18),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutUsPage(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: darkGreen2, width: 1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              height:
                                  getProportionateScreenHeight(0.08), //0.15*0.5
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(7),
                              child: const Text(
                                '關於我們',
                                style:
                                    TextStyle(color: lightGreen1, fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalSpacing(percent: 0.01),
                DefaultWilderButton(
                  text: "登出",
                  backgroundColor: menuDarkGreenColor.withOpacity(0.8),
                  textColor: selectedColor,
                  onpressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                    // 一旦登出就把 session 清掉
                    UserData.token = "";
                    StreamSocket.dispose();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> modifyEmailAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkGreen2,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
          title: const Text(
            '修改信箱',
            style: TextStyle(color: unselectedColor),
          ),
          content: Form(
            key: globalFormKeyofEmail,
            child: TextFormField(
              style: const TextStyle(color: unselectedColor),
              keyboardType: TextInputType.emailAddress,
              validator: (input) {
                if (input!.isEmpty ||
                    !RegExp(r'[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+')
                        .hasMatch(input)) {
                  //allow upper and lower case alphabets and space
                  return "Email number should be valid";
                } else {
                  return null;
                }
                ;
              },
              onSaved: (input) => requestModel.email = input!,
              decoration: InputDecoration(
                hintText: "Your new email here",
                hintStyle: TextStyle(color: unselectedColor.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.email, color: unselectedColor,),
                enabledBorder: const UnderlineInputBorder(      
                  borderSide: BorderSide(color: unselectedColor),   
                ),  
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: lightGreen0),
                ), 
                focusColor: unselectedColor
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(unselectedColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: const Text(
                '取消',
                style: TextStyle(color: darkGreen2),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(unselectedColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: const Text(
                '修改',
                style: TextStyle(color: darkGreen2),
              ),
              onPressed: () {
                if (validateAndSave(globalFormKeyofEmail)) {
                  setState(() {
                    // show waiting signal while click accept btn
                    isApiCallProcess = true;
                  });
                  APIService apiService = APIService();
                  apiService.updateUserInfo(requestModel).then((value) {
                    if (value) {
                      // 修改成功
                      setState(() {
                        isApiCallProcess = false;
                      });
                      Fluttertoast.showToast(msg: "更新成功");
                      Navigator.of(context).pop(const SettingPage());
                    } else {
                      setState(() {
                        isApiCallProcess = false;
                      });
                      Fluttertoast.showToast(msg: "更新失敗");
                      Navigator.pop(context); // 關閉 AlertDialog
                    }
                  },);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> modifyPhoneAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkGreen2,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
          title: const Text(
            '修改電話號碼',
            style: TextStyle(color: unselectedColor),
          ),
          content: Form(
            key: globalFormKeyofPhone,
            child: TextFormField(
              style: const TextStyle(color: unselectedColor),
              keyboardType: TextInputType.phone,
              validator: (input) {
                if (input!.isEmpty ||
                    !RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
                        .hasMatch(input)) {
                  //allow upper and lower case alphabets and space
                  return "Phone number should be valid";
                } else {
                  return null;
                }
                ;
              },
              //validator: (input) => input!.length < 10 ? "Phone Number should be Valid" : null, // 檢查電話號碼格式
              onSaved: (input) => requestModel.phone = input!.toString(),
              decoration: InputDecoration(
                hintText: "Your new phone here",
                hintStyle: TextStyle(color: unselectedColor.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.phone, color: unselectedColor,),
                enabledBorder: const UnderlineInputBorder(      
                  borderSide: BorderSide(color: unselectedColor),   
                ),  
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: lightGreen0),
                ), 
                focusColor: unselectedColor
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(unselectedColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(unselectedColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
              child: const Text('修改'),
              onPressed: () {
                if (validateAndSave(globalFormKeyofPhone)) {
                  setState(() {
                    // show waiting signal while click accept btn
                    isApiCallProcess = true;
                  });
                  APIService apiService = APIService();
                  apiService.updateUserInfo(requestModel).then(
                    (value) {
                      if (value) {
                        // 修改成功
                        setState(() {
                          isApiCallProcess = false;
                        });
                        Fluttertoast.showToast(msg: "更新成功");
                        Navigator.of(context).pop(const SettingPage());
                      } else {
                        setState(() {
                          isApiCallProcess = false;
                        });
                        Fluttertoast.showToast(msg: "更新失敗");
                        Navigator.pop(context); // 關閉 AlertDialog
                      }
                    },
                  );
                }
              },
            )
          ],
        );
      },
    );
  }

  bool validateAndSave(inputKey) {
    final form = inputKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
