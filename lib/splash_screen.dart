import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:katip/entity/davalar.dart';
import 'package:katip/entity/person.dart';
import 'package:katip/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String route = "/splash";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<bool> future;
  late dynamic data;

  Future<bool> initApp() async {
    final response = await http
        .get(Uri.parse('https://bpv.tr/davalar/${Person.person.mail}'));

    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      Dava.davalar = Dava.listFromJson(data);
      // for (var dava in Dava.davalar) {
      //   Dava.selectedDates.add(dava.baslamaTarihi);
      // }
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    future = initApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sayfa arka planını siyah yap
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              });
            }

            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(height: 20), // Progress bar ile yazı arasına boşluk
                  Text(
                    "Katip Yükleniyor...", // Ekranda gösterilecek yazı
                    style: TextStyle(
                      color: Colors.white, // Yazı rengi
                      fontSize: 18, // Yazı boyutu
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
