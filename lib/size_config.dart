// catch acreen size
import 'package:flutter/material.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? noteBarHeight;
  static double? screenWidth;
  static double? screenHeight;
  static double? defaultSize;
  static Orientation? orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    noteBarHeight = MediaQuery.of(context).padding.top; // catch mobile's notification bar height
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    orientation = _mediaQueryData!.orientation;
  }
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double heightPercent) {
  double? screenHeight = SizeConfig.screenHeight;
  // 815 is the layout height that designer use
  //return (inputHeight / 815.0) * screenHeight!;
  return screenHeight! * heightPercent ;
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double widthPercent) {
  double? screenWidth = SizeConfig.screenWidth;
  // 414 is the layout width that designer use 
  return screenWidth! * widthPercent;
}

// For add free space vertically 
class VerticalSpacing extends StatelessWidget {
  const VerticalSpacing({
    Key? key,
    this.percent = 0,
  }) : super(key: key);

  final double percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getProportionateScreenHeight(percent),
    );
  }
}