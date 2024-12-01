import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:katip/entity/person.dart'; // Person dosyasını içe aktar
import 'package:http/http.dart' as http;
import 'calendar.dart'; // Takvim sayfasına geçiş için
import 'saved.dart'; // Kaydedilenler sayfasına geçiş için
import 'new.dart'; // Yeni sayfasına geçiş için
import 'home.dart'; // Ana sayfa için import
import 'login.dart'; // Login sayfası için import

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<http.Response> updateName(
      String event, Person user, String name, String? surname) {
    return http.post(
      Uri.parse('https://bpv.tr/users/update/$event'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "name": name,
        "surname": surname.toString() == "Null"?"":surname.toString(),
        "mail": user.mail
      }),
    );
  }

  Future<http.Response> updatePassw(String event, Person user) {
    return http.post(
      Uri.parse('https://bpv.tr/users/update/$event'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "mail": user.mail,
        "oldPassword": _oldPasswordController.text,
        "hashedPassword": _newPasswordController.text
      }),
    );
  }

  Future<http.Response> updateMail(String event, Person user, String text) {
    return http.post(
      Uri.parse('https://bpv.tr/users/update/$event'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"oldMail": user.mail, "newMail": text}),
    );
  }

  Future<void> getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Resim seçilmişse, dosya olarak döndür
      File file = File(image.path);
      await uploadFile(file);
      http.Response message =
          await updateImg(Person.person, image.name.toString());
      Map<String, dynamic> jsonResponse = jsonDecode(message.body);
      setState(() {
        Person.person = Person.fromJson(jsonResponse);
      });

      log(Person.person.imgname.toString());
    }
  }

  Future<http.Response> updateImg(Person user, String text) {
    return http.post(
      Uri.parse('https://bpv.tr/users/img'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"mail": user.mail, "imgname": text}),
    );
  }

  Future<http.Response> uploadFile(File image) async {
    // URL'yi ayarlayın
    final Uri url = Uri.parse('https://bpv.tr/file/upload');

    // Multipart request oluşturun
    var request = http.MultipartRequest('POST', url);

    // Başlıkları ayarlayın
    request.headers['Content-Type'] = 'multipart/form-data';

    // Resmi ekleyin
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    // İsteği gönderin ve yanıtı döndürün
    var response = await request.send();
    return await http.Response.fromStream(response);
  }

  int _selectedIndex = 4; // Profil sayfası için seçili menü indeksi
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _oldPasswordController.text =
        '********'; // Eski parolayı varsayılan olarak ayarlayabilirsiniz
    _newPasswordController.text =
        '********'; // Yeni parolayı varsayılan olarak ayarlayabilirsiniz
  }

  @override
  Widget build(BuildContext context) {
    final Person person =
        Person.person; // Person sınıfından gelen bilgileri burada kullanacağız

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Profil Sayfası',
          style: GoogleFonts.merriweather(
            color: Colors.white70,
          ),
        ),
        backgroundColor: Color(0xFF252525),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Profil Kartı
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF363636),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toTitleCase('${person.name} ${person.surname}'),
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // Tıklama olayı burada işlenecek
                        await getImage();
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: Person.person.imgname != null
                            ? NetworkImage(
                                'https://bpv.tr/file/${Person.person.imgname}')
                            : const AssetImage('assets/default-profile.png')
                                as ImageProvider, // Varsayılan resim
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Profil Bilgileri Kartı
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF404040),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildProfileField(
                        context,
                        'Ad Soyad:',
                        toTitleCase('${person.name} ${person.surname}'),
                        "name"),
                    SizedBox(height: 20),
                    buildProfileField(context, 'E-Mail:', person.mail, "mail"),
                    SizedBox(height: 20),
                    buildPasswordFields(),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Çıkış Yap Butonu
              ElevatedButton(
                onPressed: () async {
                  const FlutterSecureStorage secureStorage =
                      FlutterSecureStorage();
                  await secureStorage.deleteAll();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LoginPage()), // Login sayfasına yönlendir
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF363636), // Buton rengi
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Çıkış Yap',
                  style: GoogleFonts.merriweather(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      // Menü Ekleme
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF252525),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/home-line-icon.png')),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/saved-line-icon.png')),
              label: 'Kaydedilenler',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/new-line-icon.png')),
              label: 'Yeni',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/calendar-line-icon.png')),
              label: 'Takvim',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/profile-activate-icon.png')),
              label: 'Profil',
            ),
          ],
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            } else if (index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SavedPage()));
            } else if (index == 2) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewRegistrationPage()));
            } else if (index == 3) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CalendarPage()));
            }
          },
        ),
      ),
    );
  }

  // Profil bilgisi ve düzenleme butonu için yardımcı fonksiyon
  Widget buildProfileField(
      BuildContext context, String label, String value, String event) {
    TextEditingController _controller = TextEditingController(text: value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        TextFormField(
          controller: _controller,
          style: GoogleFonts.merriweather(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          obscureText:
              label.contains('Parola'), // Parola alanlarında metni gizle
          onFieldSubmitted: (newValue) {},
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFF505050),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 8), // Buton ile text alanı arasında boşluk
        Align(
          alignment: Alignment.centerRight, // Butonu sağa yasla
          child: ElevatedButton(
            onPressed: () async {
              if (event == "name") {
                http.Response message = await updateName(
                    event,
                    Person.person,
                    _controller.text.split(' ')[0],
                    _controller.text.split(' ')[1]);
                Map<String, dynamic> jsonResponse = jsonDecode(message.body);
                setState(() {
                  Person.person = Person.fromJson(jsonResponse);
                });
              } else {
                http.Response message =
                    await updateMail(event, Person.person, _controller.text);
                Map<String, dynamic> jsonResponse = jsonDecode(message.body);
                setState(() {
                  Person.person = Person.fromJson(jsonResponse);
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF363636),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Düzenle',
              style: GoogleFonts.merriweather(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Eski ve yeni parolayı tek bir satıra koyma fonksiyonu
  Widget buildPasswordFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Eski Parola:',
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              TextFormField(
                controller: _oldPasswordController,
                style: GoogleFonts.merriweather(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF505050),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 20), // İki alan arasında boşluk
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yeni Parola:',
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              TextFormField(
                controller: _newPasswordController,
                style: GoogleFonts.merriweather(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF505050),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
// Parola alanındaki Düzenle butonu
        Padding(
          padding:
              const EdgeInsets.only(top: 20.0), // 4px aşağıya indirmek için
          child: ElevatedButton(
            onPressed: () {
              updatePassw("passw", Person.person);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF363636),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Düzenle',
              style: GoogleFonts.merriweather(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Ad Soyad Baş Harfleri Büyük Yapma Fonksiyonu
  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
