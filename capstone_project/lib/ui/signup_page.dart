import 'package:flutter/foundation.dart';
import 'package:capstone_project/services/api_service.dart';
import 'package:capstone_project/components/default_buttons.dart';
import 'package:capstone_project/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/components/loadingAnimation.dart';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/signup_model.dart';
import 'package:capstone_project/size_config.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();
  bool hidePassword = true;
  late SignUpRequestModel requestModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    requestModel = new SignUpRequestModel(
      name: '',
      account: '', 
      password: '', 
      email:'', 
      phone: '', 
    );
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

    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: PrimaryLightYellow,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(10),
            vertical: getProportionateScreenHeight(90)
          ),
          child: Form(
            key: globalFormKey,
            child: Column(
              children: <Widget>[
                Text(
                  "ши╗х??", 
                  style: Theme.of(context).textTheme.headline2,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    onSaved: (input) => requestModel.name = input!,
                    validator: (input) => /*!*/input!.contains("'") 
                      ? "User Name should be Valid" 
                      : null,
                    decoration: const InputDecoration(
                      labelText: "User Name",
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    onSaved: (input) => requestModel.account = input!,
                    validator: (input) => /*!*/input!.length<5 
                      ? "Account length need to be more than 5 characters" 
                      : null,
                    decoration: const InputDecoration(
                      //prefixIcon: Icon(Icons.person),
                      labelText: "Account",
                      //hintText: "Your birthday",
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (input) => requestModel.email = input!,
                    validator: (input) => !input!.contains("@") 
                      ? "Email ID should be Valid" 
                      : null,
                    decoration: const InputDecoration(
                      //prefixIcon: Icon(Icons.person),
                      labelText: "Mail",
                      //hintText: "Your email",
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onSaved: (input) => requestModel.phone = input!,
                    validator: (input) => /*!*/input!.length!=10 
                      ? "Phone Number should be Valid" 
                      : null,
                    decoration: const InputDecoration(
                      //prefixIcon: Icon(Icons.person),
                      labelText: "Phone Number",
                      //hintText: "Your account number",
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    onSaved: (input) => requestModel.password = input!,
                    validator: (input) => input!.length<3 
                      ? "Password should be more than 3 characters." 
                      : null,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.remove_red_eye),
                      labelText: "Password",
                      //hintText: "Your password",
                    ),
                  ),
                ),
                Container( // FIXME 0810 : check password's judge need to finish
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    onSaved: (input) => requestModel.name = input!,
                    validator: (input) => input!.length<3 
                      ? "Password should be more than 3 character" 
                      : null,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.remove_red_eye),
                      labelText: "Check Password",
                      hintText: "Input your password again",
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.0,
                ),
                DefaultWilderButton(
                  text: "ши╗х??",
                  onpressed: () {
                    if(validateAndSave()) {
                      setState(() {
                        isApiCallProcess = true;
                      });
                      print(requestModel.toJson());
                      APIService apiService = new APIService();
                      apiService.signup(requestModel).then((value) {
                        if (value) {
                          setState(() {
                            isApiCallProcess = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyBottomBar(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupPage(),
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
