import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';
import 'package:capstone_project/size_config.dart';

class DefaultWilderButton extends StatelessWidget {
  const DefaultWilderButton({ // button onPressed 的方法透過建構傳入
    Key? key,
    required this.text,
    required this.onpressed,
  }) : super(key: key);
  final String text;
  final Function() onpressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenHeight(300),
      // width: double.infinity, //to be as big as my parent allows (double.infinity)
      height: getProportionateScreenHeight(50),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), //圓角
        color: PrimaryMiddleYellow,
        onPressed: onpressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(20),
            color: PrimaryDarkGreen,
          ),
        ),
      ),
    );
  }
}
class DefaultSmallButton extends StatelessWidget {
  const DefaultSmallButton({ // button onPressed 的方法透過建構傳入
    Key? key,
    required this.text,
    required this.onpressed,
  }) : super(key: key);
  final String text;
  final Function() onpressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenHeight(150),
      // width: double.infinity, //to be as big as my parent allows (double.infinity)
      height: getProportionateScreenHeight(50),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), //圓角
        color: PrimaryMiddleYellow,
        onPressed: onpressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(20),
            color: PrimaryDarkGreen,
          ),
        ),
      ),
    );
  }
}