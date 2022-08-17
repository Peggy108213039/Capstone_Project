// loading(circling) animation
import 'package:flutter/material.dart';
import 'package:capstone_project/constants.dart';

class ProgressHUD extends StatelessWidget {
  final Widget child ;
  final bool inAsyncCall;
  final double opacity;
  final Color color;
  //final Animation<Color> valueColor;

  ProgressHUD({
    Key? key,
    required this.child,
    required this.inAsyncCall,
    this.opacity = 0.4,
    this.color = PrimaryBrown,
    //this.valueColor = Animation<Color>,
  }) : super(key:key);

  Widget build(BuildContext context) {
    List<Widget> widgetList = <Widget>[];
    widgetList.add(child);
    if(inAsyncCall) { // while isAsyncCall loading icon should reveal
      final modal = new Stack(
        children: [
          new Opacity(
            opacity: opacity,
            child: ModalBarrier(dismissible: false, color: color),
          ),
          new Center(
            child: new CircularProgressIndicator(),
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