// import 'package:flutter/foundation.dart';
import 'package:capstone_project/ui/login_page.dart';
import 'package:flutter/material.dart';
// basic setting
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/size_config.dart';
import 'package:capstone_project/components/loadingAnimation.dart';
import 'package:capstone_project/components/default_buttons.dart';
import 'package:capstone_project/bottom_bar.dart';
// service
import 'package:capstone_project/services/http_service.dart';
// model
import 'package:capstone_project/models/signup_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  late SignUpRequestModel requestModel;
  bool isApiCallProcess = false;
  // check password
  String password = "";
  String checkpassword = "";

  @override
  void initState() {
    super.initState();
    requestModel = SignUpRequestModel(
      name: '',
      account: '',
      password: '',
      email: '',
      phone: '',
    );
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

    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image:
              DecorationImage(image: introBackgroundImage, fit: BoxFit.cover)),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: transparentColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(0.1),
                vertical: SizeConfig.noteBarHeight! * 1.5),
            child: Form(
              key: globalFormKey,
              child: Column(
                children: <Widget>[
                  const VerticalSpacing(percent: 0.1),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      onSaved: (input) => requestModel.name = input!,
                      validator: (input) {
                        if (input!.isEmpty ||
                            !RegExp(r'^[\u4E00-\u9FFF\u3400-\u4DBF\u20000-\u2A6DF\u2A700-\u2B73F\u2B740-\u2B81F\u2B820-\u2CEAF\u2CEB0-\u2EBEF\u30000-\u3134F\uF900-\uFAFF\u2E80-\u2EFF\u31C0-\u31EF\u3000-\u303F\u2FF0-\u2FFF\u3300-\u33FF\uFE30-\uFE4F\uF900-\uFAFF\u2F800-\u2FA1F\u3200-\u32FF\u1F200-\u1F2FF\u2F00-\u2FDF]{3,15}')
                            .hasMatch(input)){
                          //allow upper and lower case alphabets and space
                          return "請輸入有效的使用者名稱";
                        } else {
                          return null;
                        }
                        ;
                      },
                      decoration: const InputDecoration(
                        labelText: "姓名",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      onSaved: (input) => requestModel.account = input!,
                      validator: (input) {
                        if(input!.isEmpty || !RegExp(r'^[a-z0-9_-]{5,10}$').hasMatch(input)){
                          return "請輸入有效的帳號（帳號長度需介於 5~10 個字元）";
                        } else{
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        //prefixIcon: Icon(Icons.person),
                        labelText: "帳號",
                        //hintText: "Your birthday",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (input) => requestModel.email = input!,
                      validator: (input) {
                        if(input!.isEmpty || !RegExp(r'[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+').hasMatch(input)){
                          return "請輸入有效的信箱";
                        } else{
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: "信箱",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onSaved: (input) => requestModel.phone = input!,
                      validator: (input) {
                        if(input!.isEmpty || !RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$').hasMatch(input)){
                          return "請輸入有效的電話號碼";
                        } else{
                          return null;
                        }
                      },
                      decoration: const InputDecoration(
                        //prefixIcon: Icon(Icons.person),
                        labelText: "電話號碼",
                        //hintText: "Your account number",
                      ),
                    ),
                  ),
                  Container(
                    // password
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      onChanged: (input) => password = input,
                      // onSaved: (input) => requestModel.password = input!, // put input into SignUp RequestModel
                      validator: (input) =>
                          input!.length < 3 ? "密碼長度需大於 3 個字元" : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: Icon(Icons.remove_red_eye),
                        labelText: "密碼",
                        //hintText: "Your password",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      onChanged: (input) => checkpassword = input,
                      validator: (input) =>
                          checkpassword != password ? "密碼跟確認密碼不相同" : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: Icon(Icons.remove_red_eye),
                        labelText: "確認密碼",
                        hintText: "",
                      ),
                    ),
                  ),
                  const VerticalSpacing(percent: 0.05),
                  DefaultWilderButton(
                    text: "註冊",
                    backgroundColor: unselectedColor,
                    textColor: darkGreen1,
                    onpressed: () {
                      requestModel.password = checkpassword;
                      //print("INPUT PASSWORD:" + password);
                      // print("INPUT CHECKPASSWORD:" + checkpassword);
                      if (validateAndSave()) {
                        setState(() {
                          isApiCallProcess = true;
                        });
                        print(requestModel.toJson());
                        APIService apiService = APIService();
                        apiService.signup(requestModel).then((value) {
                          if (value) {
                            setState(() {
                              isApiCallProcess = false;
                            });
                            Fluttertoast.showToast(msg: "註冊成功，請重新登入");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          } else {
                            Fluttertoast.showToast(msg: "註冊失敗，請重新註冊");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupPage(),
                              ),
                            );
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
