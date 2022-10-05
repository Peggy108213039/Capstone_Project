import 'package:flutter/material.dart';
import 'package:capstone_project/size_config.dart';
import 'package:capstone_project/constants.dart';

class DefaultWilderButton extends StatelessWidget {
  const DefaultWilderButton({
    // button onPressed
    Key? key,
    required this.text,
    required this.onpressed,
  }) : super(key: key);
  final String text;
  final Function() onpressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(0.5),
      // width: double.infinity, //to be as big as my parent allows (double.infinity)
      height: getProportionateScreenHeight(0.07),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: PrimaryMiddleYellow,
        ),
        onPressed: onpressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(0.055),
            color: PrimaryDarkGreen,
          ),
        ),
      ),
    );
  }
}

class DefaultSmallButton extends StatelessWidget {
  const DefaultSmallButton({
    // button onPressed
    Key? key,
    required this.text,
    required this.onpressed,
  }) : super(key: key);
  final String text;
  final Function() onpressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(0.5),
      // width: double.infinity, //to be as big as my parent allows (double.infinity)
      height: getProportionateScreenHeight(0.05),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: PrimaryMiddleYellow),
        onPressed: onpressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(0.2),
            color: PrimaryDarkGreen,
          ),
        ),
      ),
    );
  }
}
