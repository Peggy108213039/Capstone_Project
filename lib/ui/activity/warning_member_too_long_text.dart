import 'package:capstone_project/constants.dart';
import 'package:flutter/material.dart';

class WarningMemberTooLongText extends StatefulWidget {
  final bool isStarted;
  final bool isPaused;
  const WarningMemberTooLongText(
      {Key? key, required this.isStarted, required this.isPaused})
      : super(key: key);

  @override
  State<WarningMemberTooLongText> createState() =>
      _WarningMemberTooLongTextState();
}

class _WarningMemberTooLongTextState extends State<WarningMemberTooLongText> {
  late bool isStarted;
  late bool isPaused;

  @override
  Widget build(BuildContext context) {
    isStarted = widget.isStarted;
    isPaused = widget.isPaused;
    if (!isStarted && !isPaused) {
      showActivityMemberStopTooLongText.value = false;
    }
    print('同行者停留過久  $showActivityMemberStopTooLongText');
    return ValueListenableBuilder(
      valueListenable: showActivityMemberStopTooLongText,
      builder: (context, bool value, child) => Visibility(
        visible: value,
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 229, 150),
            ),
            onPressed: () {
              showActivityMemberStopTooLongText.value = false;
              activityMemberStopTooLongText.value = '';
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                child: ValueListenableBuilder(
                  valueListenable: activityMemberStopTooLongText,
                  builder: (context, String value, child) => Text(
                    value,
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
