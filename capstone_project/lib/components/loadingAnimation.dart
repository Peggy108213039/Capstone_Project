import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';

class LoadingAnimation extends StatelessWidget {
  final Widget child;
  final bool inAsyncCall;
  final double opacity;
  final Color color;

  const LoadingAnimation({
    Key? key,
    required this.child,
    required this.inAsyncCall,
    this.opacity = 0.2,
    this.color = PrimaryBrown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = <Widget>[];
    widgetList.add(child);
    if(inAsyncCall) { // while isAsyncCall loading icon should reveal
      final modal = Stack(
        children: [
          Opacity(
            opacity: opacity,
            child: ModalBarrier(dismissible: false, color: color),
          ),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
      widgetList.add(modal);
    }
    return Stack(
      children: widgetList,
    );
  }
}