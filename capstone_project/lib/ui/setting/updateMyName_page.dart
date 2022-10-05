import 'package:capstone_project/bottom_bar.dart';
import 'package:capstone_project/ui/setting/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/components/loadingAnimation.dart';
// basic setting
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/default_icons.dart';
import 'package:capstone_project/models/userInfo/updateInfo_model.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/size_config.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateMyInfoPage extends StatefulWidget {
  const UpdateMyInfoPage({Key? key}) : super(key: key);

  @override
  State<UpdateMyInfoPage> createState() => _UpdateMyInfoPageOneState();
}

class _UpdateMyInfoPageOneState extends State<UpdateMyInfoPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  // 更新資料的 model
  late UpdateInfoRequestModel requestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    requestModel = UpdateInfoRequestModel(
      uid: UserData.uid, 
      name: '', 
      account: UserData.userAccount, 
      password: UserData.password, 
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

  Widget _uiSetup(BuildContext context) {
    SizeConfig().init(context);
    double? height = SizeConfig.screenHeight;
    double? width = SizeConfig.screenWidth;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: PrimaryLightYellow,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(0.05), 
            vertical: SizeConfig.noteBarHeight! * 1.5),
            child: Form(
              key: globalFormKey,
              child:Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const DefBackIcon(navigatorPage: SettingPage()),
                      DefCheckIcon(
                          navigatorPage:const SettingPage(), 
                          onpressed: () {
                            if(validateAndSave()){
                              setState(() { // show waiting signal while click accept btn
                                isApiCallProcess = true;
                              });
                              APIService apiService = APIService();
                              apiService.updateUserInfo(requestModel).then((value) {
                                if (value){ // 修改成功
                                  setState(() {
                                    isApiCallProcess = false;
                                  });
                                  Navigator.of(context).pop(const MyBottomBar());
                                  print('【成功】更新個人資料 - 使用者名稱');
                                } else {
                                  print("【失敗】更新個人資料 - 使用者名稱");
                                  setState(() {
                                    isApiCallProcess = false;
                                  });
                                  Fluttertoast.showToast(msg: "更新使用者名稱失敗");
                                  Navigator.pop(context); // 關閉 AlertDialog
                                }
                              },);
                            };
                          }
                        ),
                    ],
                  ),
                  const VerticalSpacing(percent: 0.05,),
                  Container( // 大頭貼
                    width: getProportionateScreenWidth(0.53),
                    height: getProportionateScreenHeight(0.25),
                    decoration: BoxDecoration(
                      color: PrimaryLightYellow,
                      border: Border.all(width: 1),
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        fit: BoxFit.fill,
                        image:
                            AssetImage("assets/images/user.png"),
                      ),
                    ),
                  ),
                  const VerticalSpacing(percent: 0.05,),
                  Text( // 使用者帳號
                    "@" + UserData.userAccount,
                    style: const TextStyle(
                      color: PrimaryBrown,
                      fontSize: 25.0,
                      // fontFamily: 'popFonts'
                    ),
                  ),
                  Container( // 更改使用者名稱欄
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: UserData.userName,
                        prefixIcon: const Icon(Icons.person),
                        labelText: "使用者名稱",
                      ),
                      keyboardType: TextInputType.name,
                      onSaved: (input) => requestModel.name = input!,
                      validator: (input) {
                        if(input!.isEmpty || !RegExp(r'^[a-z0-9_-]{3,15}$').hasMatch(input)){
                          //allow upper and lower case alphabets and space
                          return "Phone number should be valid";
                        }else{
                          return null;
                        };
                      },
                    ),
                  ),
                ],
              ),
            )
          )
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