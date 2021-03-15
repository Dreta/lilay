import 'package:flutter/material.dart';
import 'package:lilay/ui/home/home.dart';

class Launcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lilay',
      theme: ThemeData.light(),
      home: Homepage(),
    );
  }
}
