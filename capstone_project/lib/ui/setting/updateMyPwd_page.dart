import 'package:capstone_project/bottom_bar.dart';
import 'package:capstone_project/components/default_buttons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:capstone_project/components/default_icons.dart';

import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/userInfo/updateInfo_model.dart';
import 'package:capstone_project/size_config.dart';
// import 'package:my_capstone_project_ver3/components/default_buttons.dart';
import 'package:capstone_project/components/loadingAnimation.dart';

import 'package:capstone_project/ui/setting/setting_page.dart';
// import 'package:my_capstone_project_ver3/ui/signup_page.dart';
import 'package:capstone_project/services/http_service.dart';

class UpdatePwdPage extends StatefulWidget {
  const UpdatePwdPage({Key? key}) : super(key: key);

  @override
  State<UpdatePwdPage> createState() => _UpdatePwdPageState();
}

class _UpdatePwdPageState extends State<UpdatePwdPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword1 = true;
  bool hidePassword2 = true;
  // check password
  String password = "";
  String checkpassword = "";
  // 更新資料的 model
  late UpdateInfoRequestModel requestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    requestModel = UpdateInfoRequestModel(
      uid: UserData.uid, 
      name: UserData.userName, 
      account: UserData.userAccount, 
      password: "", 
      email: UserData.userEmail, 
      phone: UserData.userPhone);
  }

  @override
  Widget build(BuildContext context){
    return LoadingAnimation(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3, 
    );
  }

  //@override
  Widget _uiSetup(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: defaultBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        key: scaffoldKey,
        // bottomNavigationBar: MyBottomBar(),
        body: SingleChildScrollView(
          child: Padding(
            // padding: EdgeInsets.only(top: SizeConfig.noteBarHeight! *2),
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(0.05),
              vertical: SizeConfig.noteBarHeight! * 1.5
            ),
            child: Form(
              key: globalFormKey,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const DefBackIcon(navigatorPage: SettingPage()),
                    ],
                  ),
                  const VerticalSpacing(percent: 0.03),
                  Container( // 原密碼核對
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: "舊密碼",
                        prefixIcon: Icon(Icons.password),
                        labelText: "舊密碼",
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (input) => requestModel.account = input!,
                      validator: (input) => /*!*/input! != UserData.password ? "與原密碼不符" : null,
                      // check if account contains @
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      onChanged: (input) => password = input,
                      onSaved: (input) => requestModel.password = input!,
                      validator: (input) => input!.length<6
                        ? "Password should be more than 6 char"
                        : null,
                        obscureText: hidePassword1,
                      decoration: InputDecoration(
                        labelText: "新密碼",
                        hintText: "新密碼",
                        prefixIcon:const  Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: (){
                            setState(() {
                              hidePassword1 = !hidePassword1;
                            });
                          },
                          icon: Icon(hidePassword1? Icons.visibility_off: Icons.visibility),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      onChanged: (input) => checkpassword = input,
                      onSaved: (input) => requestModel.password = input!,
                      validator: (input) => checkpassword != password
                        ? "密碼與確認密碼不同"
                        : null,
                        obscureText: hidePassword2,
                      decoration: InputDecoration(
                        labelText: "再次輸入新密碼",
                        hintText: "再次輸入新密碼",
                        prefixIcon:const  Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: (){
                            setState(() {
                              hidePassword2 = !hidePassword2;
                            });
                          },
                          icon: Icon(hidePassword2? Icons.visibility_off: Icons.visibility),
                        ),
                      ),
                    ),
                  ),
                  const VerticalSpacing(percent: 0.08),
                  DefaultSmallButton(
                    text: '確認',
                    backgroundColor: unselectedColor,
                    textColor: darkGreen2,
                    onpressed: (){
                      if(validateAndSave()){
                        requestModel.password = checkpassword;
                        setState(() { // show waiting signal while click accept btn
                          isApiCallProcess = true;
                        });
                        APIService apiService = APIService();
                        apiService.updateUserInfo(requestModel).then((value) {
                          if (value){ // 修改成功
                            setState(() {
                              isApiCallProcess = false;
                            });
                            Navigator.of(context).pop(const SettingPage());
                            print('【成功】更新個人資料 - 密碼');
                          } else {
                            print("【失敗】更新個人資料 - 密碼");
                            setState(() {
                              isApiCallProcess = false;
                            });
                            Fluttertoast.showToast(msg: "更新密碼失敗");
                            Navigator.pop(context); // 關閉 AlertDialog
                          }
                        },);
                      };
                    })
                ],
              ),
            )
          ),
        ),

      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if(form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
