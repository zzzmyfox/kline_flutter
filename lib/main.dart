import 'package:flutter/material.dart';
import 'package:kchart/example.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kchart",
      home: Example(),
    );
  }
}
