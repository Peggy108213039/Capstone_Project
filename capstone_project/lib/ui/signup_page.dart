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
                  Text(
                    "註冊",
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  const VerticalSpacing(percent: 0.05),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      onSaved: (input) => requestModel.name = input!,
                      validator: (input) {
                        if (input!.isEmpty ||
                            !RegExp(r'^[A-Za-z0-9_-]{3,15}$').hasMatch(input)) {
                          //allow upper and lower case alphabets and space
                          return "請輸入有效的使用者名稱";
                        } else {
                          return null;
                        }
                        ;
                      },
                      decoration: const InputDecoration(
                        labelText: "User Name",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      onSaved: (input) => requestModel.account = input!,
                      validator: (input) => /*!*/ input!.length < 5
                          ? "帳號長度需大於 5 個字元"
                          : null,
                      decoration: const InputDecoration(
                        //prefixIcon: Icon(Icons.person),
                        labelText: "Account",
                        //hintText: "Your birthday",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (input) => requestModel.email = input!,
                      validator: (input) =>
                          !input!.contains("@") ? "請輸入有效的電子信箱" : null,
                      decoration: const InputDecoration(
                        //prefixIcon: Icon(Icons.person),
                        labelText: "Mail",
                        //hintText: "Your email",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      onSaved: (input) => requestModel.phone = input!,
                      validator: (input) => /*!*/ input!.length != 10
                          ? "請輸入有效的電話號碼"
                          : null,
                      decoration: const InputDecoration(
                        //prefixIcon: Icon(Icons.person),
                        labelText: "Phone Number",
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
                        labelText: "Password",
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
                        labelText: "Check Password",
                        hintText: "Input your password again",
                      ),
                    ),
                  ),
                  const VerticalSpacing(percent: 0.05),
                  DefaultWilderButton(
                    text: "註冊",
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
                            Fluttertoast.showToast(msg: "SignUp Successful");
                            Fluttertoast.showToast(
                                msg: "Please Login after Signup Successful");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          } else {
                            Fluttertoast.showToast(msg: "SignUp Failed");
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
