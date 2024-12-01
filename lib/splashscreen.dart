// splashscreen.dart
import 'package:flutter/material.dart';
import 'package:katip/home.dart'; // HomePage'i import ediyoruz
import 'package:google_fonts/google_fonts.dart'; // GoogleFonts paketi

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();

    // 2 saniye sonra HomePage'e yönlendirme
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // HomePage'e yönlendirme
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DAHA SONRA LOGO EKLENECEK
            // Image.asset(
            // 'assets/splash-logo.png', // Splash Screen için bir logo
            // height: 120,
            // width: 120,
            //),
            SizedBox(height: 20),
            // CircularProgressIndicator'ı büyütmek için SizedBox ile boyut ayarlıyoruz
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                strokeWidth: 6.0, // Çizginin kalınlığı
                color: Colors.amber, // İlerleme çubuğu rengi
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Katip Yükleniyor...',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
