import 'package:capstone_project/models/ui_model/alert_dialog_model.dart';
import 'package:flutter/material.dart';

class InputDialog {
  BuildContext context;
  String myTitle;
  String myContent;
  String defaultText;
  String inputFieldName;
  String btn1Text;
  String btn2Text;

  late Widget inputField;
  late Widget btn1;
  late Widget btn2;

  late String inputValue;
  late MyAlertDialog myAlertDialog; // 不一定會用到，當使用者未輸入時才會生成

  InputDialog(
      {required this.context,
      required this.myTitle,
      required this.myContent,
      required this.defaultText,
      required this.inputFieldName,
      required this.btn1Text,
      required this.btn2Text}) {
    inputValue = defaultText;
    inputField = TextField(
      // 在輸入欄位顯示檔案名稱
      controller: TextEditingController()..text = defaultText,
      onChanged: (String value) {
        inputValue = value;
        // print('======== input value $inputValue ========');
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: inputFieldName,
      ),
    );
    if (btn1Text == '') {
      btn1 = const SizedBox.shrink();
    } else {
      btn1 = TextButton(
          onPressed: () async {
            // print('inputValue $inputValue');
            // 判斷有沒有輸入
            if (inputValue.isEmpty || inputValue == '') {
              // 跳出警告訊息
              myAlertDialog = MyAlertDialog(
                  context: context,
                  titleText: '沒有輸入$inputFieldName',
                  contentText: '請輸入$inputFieldName',
                  btn1Text: '確認',
                  btn2Text: '取消');
              await myAlertDialog.show();
              return;
            }
            // 回傳 inputValue
            Navigator.of(context).pop([true, inputValue]);
          },
          child: Text(btn1Text));
    }
    if (btn2Text == '') {
      btn2 = const SizedBox.shrink();
    } else {
      btn2 = TextButton(
          onPressed: () {
            Navigator.of(context).pop([false]);
          },
          child: Text(btn2Text));
    }
  }

  Future<List?> show() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(myTitle),
            content: Text(myContent),
            actions: [
              inputField,
              Row(
                children: [
                  btn1,
                  btn2,
                ],
              )
            ],
          );
        });
  }
}
