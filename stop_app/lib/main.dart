import 'package:flutter/material.dart';
import 'package:stop_app/bottom_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomButton(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}