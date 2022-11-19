import 'package:capstone_project/constants.dart';
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
      titleWidget = Text(
        titleText,
        style: const TextStyle(
            color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
      );
    }
    if (contentText == '') {
      contentWidget = const SizedBox.shrink();
    } else {
      contentWidget = Text(
        contentText,
        style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
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
    }
    if (btn2Text == '') {
      btn2 = const SizedBox.shrink();
    } else {
      btn2 = ElevatedButton(
        child: Text(btn2Text),
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
                children: [btn1, btn2],
              )
            ],
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24))),
          );
        });
  }
}
