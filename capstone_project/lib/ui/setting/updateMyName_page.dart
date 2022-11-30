import 'dart:io';
import 'package:capstone_project/bottom_bar.dart';
import 'package:capstone_project/components/default_buttons.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:capstone_project/services/file_provider.dart';
import 'package:capstone_project/services/sqlite_helper.dart';
import 'package:capstone_project/ui/setting/setting_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/components/loadingAnimation.dart';
// basic setting
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/components/default_icons.dart';
import 'package:capstone_project/models/userInfo/updateInfo_model.dart';
import 'package:capstone_project/services/http_service.dart';
import 'package:capstone_project/services/notification_service.dart';
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
  final FileProvider fileProvider = FileProvider();
  // 更新資料的 model
  late UpdateInfoRequestModel requestModel;
  bool isApiCallProcess = false;

  late MyAlertDialog noFileAlertDialog;
  late MyAlertDialog reChooseAlertDialog;

  @override
  void initState() {
    super.initState();
    requestModel = UpdateInfoRequestModel(
      uid: UserData.uid, 
      name: '', 
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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: defaultBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
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
                      children: const <Widget>[
                        DefBackIcon(navigatorPage: SettingPage()),
                      ],
                    ),
                    const VerticalSpacing(percent: 0.05,),
                    GestureDetector(
                      onTap: (){
                        addMyPhoto(context);
                      },
                      child: Container(
                        width: getProportionateScreenWidth(0.53),
                        height: getProportionateScreenHeight(0.25),
                        decoration: const BoxDecoration(
                          color: unselectedColor,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                              image: defaultUserImage,
                          ),
                        ),
                      )
                    ),
                    const VerticalSpacing(percent: 0.05,),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabled: false,
                          prefixIcon: const Icon(Icons.person),
                          labelText: UserData.userAccount,
                          //labelStyle: TextStyle(color: grassGreen)
                        ),
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
                          if(input!.isEmpty || 
                              !RegExp(r'^[\u4E00-\u9FFF\u3400-\u4DBF\u20000-\u2A6DF\u2A700-\u2B73F\u2B740-\u2B81F\u2B820-\u2CEAF\u2CEB0-\u2EBEF\u30000-\u3134F\uF900-\uFAFF\u2E80-\u2EFF\u31C0-\u31EF\u3000-\u303F\u2FF0-\u2FFF\u3300-\u33FF\uFE30-\uFE4F\uF900-\uFAFF\u2F800-\u2FA1F\u3200-\u32FF\u1F200-\u1F2FF\u2F00-\u2FDF]{3,15}')
                              .hasMatch(input)){
                            //allow upper and lower case alphabets and space
                            return "Username should be valid";
                          }else{
                            return null;
                          };
                        },
                      ),
                    ),
                    const VerticalSpacing(percent: 0.05,),
                    DefaultSmallButton(
                      text: '確認',
                      backgroundColor: unselectedColor,
                      textColor: darkGreen2,
                      onpressed: (){
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
                              NotificationService().showNotification(2, 'main_channel', "更新個資成功", "重新登入以更新資料");
                              Navigator.of(context).pop(const MyBottomBar(i: 2, firstTime: false));
                            } else {
                              setState(() {
                                isApiCallProcess = false;
                              });
                              Fluttertoast.showToast(msg: "更新失敗");
                              Navigator.pop(context); // 關閉 AlertDialog
                            }
                          },);
                        };
                      })
                  ],
                ),
              )
            )
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
    // 匯入軌跡
  void addMyPhoto(BuildContext context) async {
    // 抓手機上任何類型的檔案
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null) {
      noFileAlertDialog = MyAlertDialog(
          context: context,
          titleText: '沒有選擇檔案匯入',
          titleFontSize: 30,
          contentText: '',
          contentFontSize: 20,
          btn1Text: '返回',
          btn2Text: '');
      noFileAlertDialog.show();
      return;
    }

    final PlatformFile file = result.files.single;
    final String? importFilePath = file.path;
    final fileType = file.extension; // 檔案類型
    late bool? toAdd;

    if (fileType != 'jpg') {
      reChooseAlertDialog = MyAlertDialog(
          context: context,
          titleText: '請重新選擇檔案',
          titleFontSize: 30,
          contentText: '你選擇的檔案類型不是 .jpg \n請重新選擇',
          contentFontSize: 20,
          btn1Text: '返回',
          btn2Text: '');
      reChooseAlertDialog.show();
      return;
    } else {
      // late Track newTrackData;
      late File newTrackFile;
      // kml 轉 gpx
      if (fileType == 'jpg' && importFilePath != null) {
        String result =
            await fileProvider.readFileAsString(file: File(importFilePath));
        // String gpxFilePath = '${trackDir!.path}/$trackName';
        // // 匯入 kml 檔案到 app 下
        // newTrackFile = await fileProvider.writeFileAsString(
        //     content: gpxFile, path: gpxFilePath);
      }
      // 要新增的軌跡資料
      // ===================
      // String result = await fileProvider.readFileAsString(file: newTrackFile);
      // ===================

    //   if (insertTrackResponse[0]) {
    //     String tID = insertTrackResponse[1]["tID"].toString();
    //     Map<String, String> trackID = {'tID': tID};
    //     List uploadTrackResponse =
    //         await APIService.uploadTrack(newTrackFile, trackID);
    //     print(uploadTrackResponse);
    //     if (uploadTrackResponse[0]) {
    //       Track newClientTrackData = Track(
    //           tID: tID,
    //           uID: UserData.uid.toString(),
    //           track_name: fileProvider.getFileName(file: newTrackFile),
    //           track_locate: newTrackFile.path,
    //           start: DateFormat('yyyy-MM-dd hh:mm').format(startTime),
    //           finish: DateFormat('yyyy-MM-dd hh:mm').format(finishTime),
    //           total_distance: distance.toString(),
    //           time: currentDate,
    //           track_type: '0');
    //       List insertClientTrackResult = await SqliteHelper.insert(
    //           tableName: 'track', insertData: newClientTrackData.toMap());
    //       if (!insertClientTrackResult[0]) {
    //         insertClientTrackFailDialog = MyAlertDialog(
    //             context: context,
    //             titleText: '本機端新增軌跡失敗',
    //             titleFontSize: 30,
    //             contentText: insertClientTrackResult[1].toString(),
    //             contentFontSize: 20,
    //             btn1Text: '確認',
    //             btn2Text: '');
    //         insertClientTrackFailDialog.show();
    //       } else {
    //         hasTrackCheckTable = false;
    //       }
    //     } else {
    //       uploadServerTrackFailDialog = MyAlertDialog(
    //           context: context,
    //           titleText: '上傳軌跡失敗',
    //           titleFontSize: 30,
    //           contentText: uploadTrackResponse[1].toString(),
    //           contentFontSize: 20,
    //           btn1Text: '確認',
    //           btn2Text: '');
    //       uploadServerTrackFailDialog.show();
    //     }
    //   } else {
    //     insertServerTrackFailDialog = MyAlertDialog(
    //         context: context,
    //         titleText: 'server 新增軌跡失敗',
    //         titleFontSize: 30,
    //         contentText: insertTrackResponse[1].toString(),
    //         contentFontSize: 20,
    //         btn1Text: '確認',
    //         btn2Text: '');
    //     insertServerTrackFailDialog.show();
    //   }
    //   setState(() {});
    // }
    // return; // 如果沒有要匯入就 return    }
    }
  }
}