import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:katip/entity/person.dart';
import 'package:katip/home.dart';
import 'package:katip/login.dart';

class NewPasswordPage extends StatefulWidget {
  @override
  _NewPasswordPageState createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _passwordError;
  String? _confirmPasswordError;

  // Şifre doğrulama fonksiyonu
  String? _validatePassword(String password, String confirmPassword) {
    if (password.isEmpty || confirmPassword.isEmpty) {
      return "Şifre alanları boş bırakılamaz";
    } else if (password != confirmPassword) {
      return "Şifreler eşleşmiyor";
    }
    return null;
  }

  Future<http.Response> unkownPassw() {
    return http.post(
      Uri.parse('https://bpv.tr/users/unknown-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'mail': Person.email,
        'newpassw': _passwordController.text
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Yeni Şifrenizi Girin',
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
        color: const Color(0xFF060606), // Arka plan rengi
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Yeni şifrenizi girin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white, // Yazı rengi
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black45,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF8E1717)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: _passwordError,
                  errorStyle: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre Tekrarı',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black45,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF8E1717)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: _confirmPasswordError,
                  errorStyle: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _passwordError = _validatePassword(_passwordController.text,
                        _confirmPasswordController.text);
                  });

                  if (_passwordError == null) {
                    await unkownPassw();
                    // Şifre başarıyla doğrulandıysa işlemi burada yapabilirsiniz
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Şifre başarıyla güncellendi!')),
                    );
                    // Ana sayfaya veya giriş ekranına yönlendirme yapılabilir
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LoginPage()), // Ana Sayfa'ya yönlendirme
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
                  'Şifreyi Güncelle',
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
