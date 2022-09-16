import 'package:flutter/material.dart';
import 'package:capstone_project/components/loadingAnimation.dart';
// basic setting
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/default_icons.dart';
import 'package:capstone_project/models/updateInfo_model.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/size_config.dart';
import 'package:capstone_project/ui/profile_page.dart';

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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const DefBackIcon(navigatorPage: ProfilePage()),
                  DefCheckIcon(navigatorPage:const ProfilePage(), 
                    onpressed: (){
                      print("更新使用者資訊成功");
                    } 
                  ),
                ],
              ),
              const VerticalSpacing(percent: 0.02,),
              // Row(
              //   children: [
              //     LayoutBuilder(builder: (context, constraints) {
              //       double innerHeight = constraints.maxHeight;
              //       double innerWidth = constraints.maxWidth;
              //       return Center(
              //         child: Container(
              //           width: constraints.maxHeight * 0.6,
              //           height: innerWidth * 0.6,
              //           decoration: BoxDecoration(
              //             color: PrimaryLightYellow,
              //             border: Border.all(width: 1),
              //             shape: BoxShape.circle,
              //             image: const DecorationImage(
              //               fit: BoxFit.fill,
              //               image:
              //                   AssetImage("assets/images/user.png"),
              //             ),
              //           ),
              //         ),
              //       );
              //     })
              //   ],
              // ),
              // Container(
              //   decoration: const BoxDecoration(color: PrimaryMiddleYellow),
              //   height: height! * 0.55,
              //   child: LayoutBuilder(
              //     builder: (context, constraints) {
              //       double innerHeight = constraints.maxHeight;
              //       double innerWidth = constraints.maxWidth;
              //       // Stack
              //       return Stack(
              //         fit: StackFit.expand,
              //         children: [
              //           Positioned( // 文字位置
              //             top: innerHeight * 0.7,
              //             left: 0,
              //             right: 0,
              //             child: Container(
              //               height: innerHeight * 0.8,
              //               width: innerWidth,
              //               child: Column(
              //                 children: [ 
              //                   Text( // 使用者帳號（唯一，不可變）
              //                     "@" + UserData.userAccount,
              //                     style: const TextStyle(
              //                       color: PrimaryBrown,
              //                       fontSize: 25.0,
              //                       // fontFamily: 'popFonts'
              //                     ),
              //                   ),
              //                   const VerticalSpacing(percent: 0.02,),
              //                   Container( // 原密碼核對
              //                     padding: const EdgeInsets.symmetric(vertical: 10.0),
              //                     child: TextFormField(
              //                       decoration: const InputDecoration(
              //                         hintText: "舊密碼",
              //                         prefixIcon: Icon(Icons.password),
              //                         labelText: "舊密碼",
              //                       ),
              //                       keyboardType: TextInputType.name,
              //                       onSaved: (input) => requestModel.name = input!,
              //                       validator: (input) => /*!*/input! != UserData.password ? "與原密碼不符" : null,
              //                       // check if account contains @
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ),
              //           Positioned( //頭貼位置
              //             top: innerHeight * 0.05,
              //             left: 0,
              //             right: 0,
              //             child: Center(
              //               child: Container(
              //                 width: innerWidth * 0.6,
              //                 height: innerWidth * 0.6,
              //                 decoration: BoxDecoration(
              //                   color: PrimaryLightYellow,
              //                   border: Border.all(width: 1),
              //                   shape: BoxShape.circle,
              //                   image: const DecorationImage(
              //                     fit: BoxFit.fill,
              //                     image:
              //                         AssetImage("assets/images/user.png"),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           )
              //         ],
              //       );
              //     },
              //   ),
              // ),
              const VerticalSpacing(percent: 0.02,),
            ],
          ),
        ),
      ),
    );
  }
}