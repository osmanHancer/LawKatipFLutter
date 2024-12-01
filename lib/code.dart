import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:katip/new_password.dart';

class CodePage extends StatefulWidget {
  final String code; // Güncellenecek dava bilgileri

  const CodePage({super.key, required this.code});

  _CodePageState createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {

  final TextEditingController _codeController = TextEditingController();
  int _remainingTime = 120; // 120 saniye
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Süre doldu, lütfen tekrar deneyin.'),
          ),
        );
        Navigator.pop(context); // Süre dolunca geri dönme işlemi
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Doğrulama Kodu',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF060606), // AppBar arka planı
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // İkonun rengi beyaz yapıldı
          onPressed: () {
            Navigator.of(context).pop(); // Bir önceki sayfaya geri döner
          },
        ),
      ),
      body: Container(
        color: const Color(0xFF060606), // Sayfa arka plan rengi
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'E-postanıza gelen doğrulama kodunu girin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white), // Input text rengi
                decoration: InputDecoration(
                  labelText: 'Doğrulama Kodu',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black45, // TextField arka planı
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF8E1717)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Kalan Süre: ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_codeController.text.isNotEmpty && (_codeController.text == widget.code)) {
                     
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewPasswordPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen bir kod girin')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8E1717),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Doğrula',
                  style: TextStyle(color: Color(0xFF111111)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
