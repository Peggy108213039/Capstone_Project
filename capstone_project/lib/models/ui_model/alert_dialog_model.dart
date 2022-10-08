import 'package:flutter/material.dart';

class MyAlertDialog {
  BuildContext context;
  String titleText;
  String contentText;
  String btn1Text;
  String btn2Text;

  late Widget titleWidget;
  late Widget contentWidget;
  late Widget btn1;
  late Widget btn2;

  MyAlertDialog(
      {required this.context,
      required this.titleText,
      required this.contentText,
      required this.btn1Text,
      required this.btn2Text}) {
    if (titleText == '') {
      titleWidget = const SizedBox.shrink();
    } else {
      titleWidget = Text(titleText);
    }
    if (contentText == '') {
      contentWidget = const SizedBox.shrink();
    } else {
      contentWidget = Text(contentText);
    }
    if (btn1Text == '') {
      btn1 = const SizedBox.shrink();
    } else {
      btn1 = TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text(btn1Text));
    }
    if (btn2Text == '') {
      btn2 = const SizedBox.shrink();
    } else {
      btn2 = TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(btn2Text));
    }
  }

  Future<bool?> show() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: titleWidget,
            content: contentWidget,
            actions: [btn1, btn2],
          );
        });
  }
}
