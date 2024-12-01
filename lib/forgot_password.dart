import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'package:katip/code.dart';
import 'package:katip/entity/person.dart';

class ForgotPasswordPage extends StatelessWidget {

    late final String randomString;
  Future<http.Response> unkownPassw() {
     randomString = generateRandomString(5);
    return http.post(
      Uri.parse('https://bpv.tr/users/unknown-password-mail'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': _emailController.text,
        'text': randomString
      }),
    );
  }


  String generateRandomString(int length) {
    const String _chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random _rnd = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
      ),
    );
  }
final TextEditingController _emailController = TextEditingController();

  ForgotPasswordPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Parolanızı Sıfırlayın',
          style: TextStyle(color: Colors.white), // Başlık rengi beyaz
        ),
        backgroundColor: const Color(0xFF000000), // AppBar arka planı
        iconTheme:
            const IconThemeData(color: Colors.white), // Geri ikonu rengi beyaz
      ),
      body: Container(
        color: const Color(0xFF060606), // Sayfa arka plan rengi #252525
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Lütfen kaydolurken kullandığınız e-posta adresinizi girin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white, // Yazı rengi beyaz
                  fontSize: 16, // Yazı boyutu
                ),
              ),
              const SizedBox(height: 52),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white), // Input text rengi
                decoration: InputDecoration(
                  labelText: 'E-posta adresi',
                  labelStyle:
                      const TextStyle(color: Colors.white70), // Label rengi
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
              const SizedBox(height: 44),
              ElevatedButton(
                onPressed: () async {
                        http.Response message = await unkownPassw();

                  Map<String, dynamic> jsonResponse = jsonDecode(message.body);
                  if (jsonResponse["message"] ==
                      "Şifre sıfırlama e-postası gönderildi.") {
                    Person.email = _emailController.text;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CodePage(
                              code: randomString)), // CodePage'e yönlendirme
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bu mail için kayıtlı kullanıcı yok'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8E1717), // Buton rengi
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Buton kenar yuvarlama
                  ),
                ),
                child: const Text(
                  'Parola Sıfırlama Bağlantısını Gönder',
                  style: TextStyle(color: Color(0xFF111111)), // Buton yazı rengi
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
