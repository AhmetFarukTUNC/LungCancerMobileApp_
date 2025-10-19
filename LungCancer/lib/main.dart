import 'package:flutter/material.dart';
import 'package:lungcancer/Contact.dart';
import 'package:lungcancer/aboutscreen.dart';
import 'package:lungcancer/home/home.dart';
import 'package:lungcancer/login.dart';
import 'package:lungcancer/privacyscreen.dart';
import 'package:lungcancer/resultscreen.dart';
import 'package:lungcancer/uploadscreen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lung Cancer Prediction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Montserrat',
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white, // Başlık yazısı rengi
          backgroundColor: Colors.deepPurple, // AppBar arkaplan rengi
        ),
      ),
      home: LoginPage(),
    );
  }

}








