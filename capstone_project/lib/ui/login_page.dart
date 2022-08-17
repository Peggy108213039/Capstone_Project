import 'package:capstone_project/components/default_buttons.dart';
import 'package:capstone_project/bottom_bar.dart';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/size_config.dart';
import 'package:capstone_project/ui/signup_page.dart';
import 'package:flutter/material.dart';

import '../components/loadingAnimation.dart';
import '../services/api_service.dart';
import '../models/login_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();
  bool hidePassword = true;
  late LoginRequestModel requestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    requestModel = new LoginRequestModel(account: '', password: '');
  }

  @override
  Widget build(BuildContext context){
    return ProgressHUD(
      child: _uiSetup(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3, 
    );
  }

  @override
  Widget _uiSetup(BuildContext context) {
    SizeConfig().init(context);
    //double width = MediaQuery.of(context).size.width;
    //double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: PrimaryLightYellow,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(10),
            vertical: getProportionateScreenHeight(120)
          ),
          child: Form(
            key: globalFormKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center, //FIXME：垂直置中問題
              children: <Widget>[
                Text(
                  "登入", 
                  style: Theme.of(context).textTheme.headline2,
                ),
                VerticalSpacing(of: 60),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (input) => requestModel.account = input!,
                    validator: (input) => /*!*/input!.contains("@") ? "Email ID should be Valid" : null,
                    // check if account contains @
                    decoration: new InputDecoration(
                      hintText: "Your account number",
                      prefixIcon: Icon(Icons.person),
                      labelText: "Account",
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    onSaved: (input) => requestModel.password = input!,
                    validator: (input) => input!.length<3
                      ? "Password should be more than 6 char"
                      : null,
                      obscureText: hidePassword,
                    decoration: new InputDecoration(
                      labelText: "Password",
                      hintText: "Your password number",
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: (){
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(hidePassword? Icons.visibility_off: Icons.visibility),
                      ),
                    ),
                  ),
                ),
                VerticalSpacing(of:50),
                DefaultWilderButton(
                  text: "登入",
                  onpressed: () {
                    if(validateAndSave()) {
                      setState(() {
                        isApiCallProcess = true;
                      });
                      APIService apiService = APIService();
                      apiService.login(requestModel).then((value) {
                        if (value) { // login 成功
                          setState(() {
                            isApiCallProcess = false;
                          });
                          print(requestModel.toJson());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyBottomBar(),
                            ),
                          );
                        } else { // login failed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        }
                      });
                    }
                  },
                ),
                VerticalSpacing(of: 10),
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
}
