import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:capstone_project/constants.dart';
import 'package:capstone_project/size_config.dart';
import 'package:capstone_project/components/default_buttons.dart';
import 'package:capstone_project/components/loadingAnimation.dart';

import 'package:capstone_project/bottom_bar.dart';
import 'package:capstone_project/ui/signup_page.dart';

import 'package:capstone_project/models/login_model.dart';
import 'package:capstone_project/services/http_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  bool hidePassword = true;
  late LoginRequestModel requestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    requestModel = LoginRequestModel(account: '', password: '');
  }

  @override
  Widget build(BuildContext context) {
    return LoadingAnimation(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
    );
  }

  //@override
  Widget _uiSetup(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    print('width: $width, height: $height');
    SizeConfig().init(context);
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
              // padding: EdgeInsets.only(top: SizeConfig.noteBarHeight! *2),
              padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(0.1),
                  vertical: SizeConfig.noteBarHeight! * 2),
              child: Form(
                key: globalFormKey,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center, //FIXME：垂直置中問題
                  children: <Widget>[
                    // Text(
                    //   "登入",
                    //   style: Theme.of(context).textTheme.headline2,
                    // ),
                    Container(
                      width: width * 0.5,
                      height: width * 0.5,
                      decoration: const BoxDecoration(
                          color: darkGreen1, shape: BoxShape.circle),
                    ),
                    const VerticalSpacing(percent: 0.1),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: "Your account number",
                          prefixIcon: Icon(Icons.person),
                          labelText: "Account",
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (input) => requestModel.account = input!,
                        validator: (input) => /*!*/ input!.contains("@")
                            ? "Email ID should be Valid"
                            : null,
                        // check if account contains @
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        onSaved: (input) => requestModel.password = input!,
                        validator: (input) => input!.length < 3
                            ? "Password should be more than 6 char"
                            : null,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Your password number",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                      ),
                    ),
                    const VerticalSpacing(percent: 0.1),
                    DefaultWilderButton(
                      text: "登入",
                      onpressed: () {
                        if (validateAndSave()) {
                          setState(() {
                            isApiCallProcess = true;
                          });
                          APIService apiService = APIService();
                          apiService.login(requestModel).then((value) {
                            if (value) {
                              // 成功登入
                              setState(() {
                                isApiCallProcess = false;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyBottomBar(
                                    i: 2,
                                    firstTime: true,
                                  ),
                                ),
                              );
                            } else {
                              // login failed
                              setState(() {
                                isApiCallProcess = false;
                              });
                              // Login Failed Hint Box
                              Fluttertoast.showToast(msg: "Login Failed");
                            }
                          });
                        }
                      },
                    ),
                    const VerticalSpacing(percent: 0.02),
                    DefaultWilderButton(
                      text: "註冊",
                      onpressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )),
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
