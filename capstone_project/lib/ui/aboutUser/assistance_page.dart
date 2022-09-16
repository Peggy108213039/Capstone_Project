import 'package:flutter/material.dart';

class AssistancePage extends StatefulWidget {
  const AssistancePage({Key? key}) : super(key: key);

  @override
  State<AssistancePage> createState() => _AssistancePageState();
}

class _AssistancePageState extends State<AssistancePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '協助工具',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
