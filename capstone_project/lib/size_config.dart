// �B�z�ؤo�ഫ����k
import 'package:flutter/material.dart';

class SizeConfig {
  // ���קK����ù��s���B��e��
  // SafeArea �i�q�L MediaQuery �˴��ù��ؤo�A�����ε{�����j�p��P�ù����հt
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? defaultSize;
  static Orientation? orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    orientation = _mediaQueryData!.orientation;
  }
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double? screenHeight = SizeConfig.screenHeight;
  // 815 is the layout height that designer use
  return (inputHeight / 815.0) * screenHeight!;
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double? screenWidth = SizeConfig.screenWidth;
  // 414 is the layout width that designer use 
  return (inputWidth / 414.0) * screenWidth!;
}

// For add free space vertically (���Z)
class VerticalSpacing extends StatelessWidget {
  const VerticalSpacing({
    Key? key,
    this.of = 25,
  }) : super(key: key);

  final double of;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getProportionateScreenHeight(of),
    );
  }
}