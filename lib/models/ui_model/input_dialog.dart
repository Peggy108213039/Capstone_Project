import 'package:capstone_project/constants.dart';
import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:flutter/material.dart';

class InputDialog {
  BuildContext context;
  String myTitle;
  double myTitleFontSize;
  String myContent;
  double myContentFontSize;
  String defaultText;
  String inputFieldName;
  String btn1Text;
  String btn2Text;

  late Widget myTitleWidget;
  late Widget myContentWidget;
  late Widget inputField;
  late Widget btn1;
  late Widget btn2;

  late String inputValue;
  late MyAlertDialog myAlertDialog; // 不一定會用到，當使用者未輸入時才會生成

  InputDialog(
      {required this.context,
      required this.myTitle,
      required this.myTitleFontSize,
      required this.myContent,
      required this.myContentFontSize,
      required this.defaultText,
      required this.inputFieldName,
      required this.btn1Text,
      required this.btn2Text}) {
    if (myTitle == '') {
      myTitleWidget = const SizedBox.shrink();
    } else {
      myTitleWidget = Text(
        myTitle,
        style: TextStyle(
            color: Colors.white,
            fontSize: myTitleFontSize,
            fontWeight: FontWeight.w500),
      );
    }
    if (myContent == '') {
      myContentWidget = const SizedBox.shrink();
    } else {
      myContentWidget = Text(
        myContent,
        style: TextStyle(
            color: Colors.white,
            fontSize: myContentFontSize,
            fontWeight: FontWeight.w500),
      );
    }
    inputValue = defaultText;
    inputField = Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        // 在輸入欄位顯示檔案名稱
        controller: TextEditingController()..text = defaultText,
        onChanged: (String value) {
          inputValue = value;
        },
        style: const TextStyle(color: darkGreen2, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
            labelText: inputFieldName,
            labelStyle: const TextStyle(
                color: darkGreen1, fontWeight: FontWeight.w400)),
      ),
    );

    if (btn1Text == '') {
      btn1 = const SizedBox.shrink();
    } else {
      btn1 = ElevatedButton(
        onPressed: () async {
          // print('inputValue $inputValue');
          // 判斷有沒有輸入
          if (inputValue.isEmpty || inputValue == '') {
            // 跳出警告訊息
            myAlertDialog = MyAlertDialog(
              context: context,
              titleText: '沒有輸入$inputFieldName',
              titleFontSize: 30,
              contentText: '請輸入$inputFieldName',
              contentFontSize: 20,
              btn1Text: '確認',
              btn2Text: '取消',
            );
            await myAlertDialog.show();
            return;
          }
          // 回傳 inputValue
          Navigator.of(context).pop([true, inputValue]);
        },
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
      );
    }
    if (btn2Text == '') {
      btn2 = const SizedBox.shrink();
    } else {
      btn2 = ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop([false]);
        },
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
      );
    }
  }

  Future<List?> show() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: darkGreen1,
            title: myTitleWidget,
            content: myContentWidget,
            actions: [
              inputField,
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
