import 'package:flutter/material.dart';
import 'package:katip/login.dart';

void main(){
  return runApp(AnaUygulama());
}

class AnaUygulama extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }

}