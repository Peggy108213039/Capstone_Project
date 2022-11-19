import 'package:flutter/material.dart';
import 'package:capstone_project/size_config.dart';
import 'package:capstone_project/constants.dart';

class DefaultWilderButton extends StatelessWidget {
  const DefaultWilderButton({
    // button onPressed
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onpressed,
  }) : super(key: key);
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Function() onpressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(0.8),
      // width: double.infinity, //to be as big as my parent allows (double.infinity)
      height: getProportionateScreenHeight(0.06),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: backgroundColor,
        ),
        onPressed: onpressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(0.055),
            color: textColor,
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
    required this.backgroundColor,
    required this.textColor,
    required this.onpressed,
  }) : super(key: key);
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Function() onpressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(0.4),
      // width: double.infinity, //to be as big as my parent allows (double.infinity)
      height: getProportionateScreenHeight(0.06),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
            backgroundColor: backgroundColor),
        onPressed: onpressed,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: getProportionateScreenWidth(0.055),
            color: textColor,
          ),
        ),
      ),
    );
  }
}
