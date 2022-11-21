import 'package:capstone_project/constants.dart';
import 'package:flutter/material.dart';

class MyAlertDialog {
  BuildContext context;
  String titleText;
  double titleFontSize;
  String contentText;
  double contentFontSize;
  String btn1Text;
  String btn2Text;

  late Widget titleWidget;
  late Widget contentWidget;
  late Widget btn1;
  late Widget btn2;
  List<Widget> btnList = [];

  MyAlertDialog({
    required this.context,
    required this.titleText,
    required this.titleFontSize,
    required this.contentText,
    required this.contentFontSize,
    required this.btn1Text,
    required this.btn2Text,
  }) {
    if (titleText == '') {
      titleWidget = const SizedBox.shrink();
    } else {
      titleWidget = Text(
        titleText,
        style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w500),
      );
    }
    if (contentText == '') {
      contentWidget = const SizedBox.shrink();
    } else {
      contentWidget = Text(
        contentText,
        style: TextStyle(
            color: Colors.white,
            fontSize: contentFontSize,
            fontWeight: FontWeight.w500),
      );
    }
    if (btn1Text == '') {
      btn1 = const SizedBox.shrink();
    } else {
      btn1 = ElevatedButton(
        child: Text(
          btn1Text,
          style: const TextStyle(fontSize: 17),
        ),
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(70, 40),
            foregroundColor: darkGreen2,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        onPressed: () {
          Navigator.of(context).pop(true);
        },
      );
      btnList.add(btn1);
    }
    if (btn2Text == '') {
      btn2 = const SizedBox.shrink();
    } else {
      btn2 = ElevatedButton(
        child: Text(
          btn2Text,
          style: const TextStyle(fontSize: 17),
        ),
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(70, 40),
            foregroundColor: darkGreen2,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        onPressed: () {
          Navigator.of(context).pop(false);
        },
      );
      btnList.add(btn2);
    }
  }

  Future<bool?> show() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: darkGreen1,
            title: titleWidget,
            content: contentWidget,
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: btnList,
              )
            ],
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24))),
          );
        });
  }
}
