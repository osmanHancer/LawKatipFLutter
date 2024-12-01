import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Utils {
  static  var jsonId = [];
  static late  SharedPreferences prefs; 
  static const Color primaryColor = Color.fromARGB(255, 11, 137, 241);
  static const Color errorColor = Colors.red;
  static const Color successColor = Color.fromRGBO(125, 180, 125, 1);
  static const Color validColor = Color.fromRGBO(215, 250, 215, 1);

  static Color backgroundColor = const Color.fromRGBO(215, 215, 215, 1);

  static late Color textColor;
  static late Color inactiveColor;

  static late Color foregroundColor;

  static void activateLightTheme() {
    textColor = const Color.fromRGBO(30, 30, 30, 1);
    inactiveColor = const Color.fromRGBO(120, 120, 120, 1);

    foregroundColor = const Color.fromRGBO(245, 245, 245, 1);
    backgroundColor = const Color.fromRGBO(215, 215, 215, 1);


  }

  static void activateDarkTheme() {
    textColor = const Color.fromRGBO(222, 222, 222, 1);
    inactiveColor = const Color.fromRGBO(120, 120, 120, 1);

    backgroundColor = const Color.fromRGBO(22, 28, 54, 1);
    foregroundColor = const Color.fromRGBO(2, 5, 16, 1);
  }

  static void timeToText(DateTime time, {showTime = true, showDate = true}) {}
}
