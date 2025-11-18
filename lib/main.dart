import 'package:flutter/material.dart';
import 'package:tt_predictor/front/pages/home.dart';
import 'package:http/http.dart' as http;

void main() {

  var homePage = Home();

  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.amberAccent,
    ),
    home: homePage,
  ));
}