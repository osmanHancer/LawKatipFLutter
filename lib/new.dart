import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart'; // Dropdown arama paketi
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart'; // Tarih için gerekli paket
import 'package:intl/date_symbol_data_local.dart'; // Takvim için gerekli paket
import 'package:google_fonts/google_fonts.dart'; // Google Fonts paketi
import 'package:katip/entity/davalar.dart';
import 'package:katip/entity/lists.dart';
import 'package:katip/entity/person.dart';
import 'package:katip/profile.dart';
import 'home.dart'; // Ana Sayfa için gerekli import
import 'saved.dart'; // Kaydedilenler sayfası için import
import 'calendar.dart'; // Takvim sayfası için gerekli import
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class NewRegistrationPage extends StatefulWidget {
  @override
  _NewRegistrationPageState createState() => _NewRegistrationPageState();
}

class _NewRegistrationPageState extends State<NewRegistrationPage> {
  final _formKey = GlobalKey<FormState>(); // Form için anahtar

  // Davacı ve Davalı Bilgileri için TextEditingController'lar
  final TextEditingController fileNumberController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController davaciTCNumasi = TextEditingController();
  final TextEditingController davaliTCNumasi = TextEditingController();
  final TextEditingController davacivekilfirstNameController =
      TextEditingController();
  final TextEditingController davacivekillastNameController =
      TextEditingController();
  final TextEditingController davacivekiladdressController =
      TextEditingController();
  final TextEditingController davacivekilTCNumasi = TextEditingController();
  final TextEditingController davalivekilfirstNameController =
      TextEditingController();
  final TextEditingController davalivekillastNameController =
      TextEditingController();
  final TextEditingController davalivekiladdressController =
      TextEditingController();
  final TextEditingController davalivekilTCNumasi = TextEditingController();
  final TextEditingController professionController = TextEditingController();

  final TextEditingController defendantFirstNameController =
      TextEditingController();
  final TextEditingController defendantLastNameController =
      TextEditingController();
  final TextEditingController defendantAddressController =
      TextEditingController();
  final TextEditingController defendantContactNumberController =
      TextEditingController();
  final TextEditingController defendantProfessionController =
      TextEditingController();
  DateTime? selectedDateTime; // Seçilen tarih ve saat
  DateTime? selectedDateTimeDurusma; // Seçilen tarih ve saat

  final maskFormatter = MaskTextInputFormatter(
      mask: '(###) ### ## ##', filter: {"#": RegExp(r'[0-9]')});

  // İletişim numarası için mask tanımlama
  final defendantMaskFormatter = MaskTextInputFormatter(
      mask: '(###) ### ## ##', filter: {"#": RegExp(r'[0-9]')});

  // Genel Bilgiler için TextEditingController'lar
  final TextEditingController caseSubjectController = TextEditingController();
  final TextEditingController startDateController =
      TextEditingController(); // Dava Başlama Tarihi için Controller

  //----------------------------------------------------------------------------------
  final TextEditingController durusmastartDateController =
      TextEditingController(); // Dava Başlama Tarihi için Controller

  final TextEditingController noteController =
      TextEditingController(); // Notlar için Controller
  List<String> ilceler = [];
  String? selectedCity; // İl seçimi için
  String? selectedAsama; // aşama seçimi
  String? selectedDistrict; // İl seçimi için
  String? selectedCourt; // Mahkeme seçimi için
  int? selectedDaire; // Dava Aşaması için
  int _selectedIndex = 2; // Yeni sayfası aktif olduğu için başlangıç değeri 2
  Future<http.Response> createDava() {
    return http.post(
      Uri.parse('https://bpv.tr/davalar/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "esasNo": fileNumberController.text,
        "mail": Person.person.mail,
        "davaciVekilAdi": davacivekilfirstNameController.text,
        "davaciVekilSoyadi": davacivekillastNameController.text,
        "davaciVekilTc": davacivekilTCNumasi.text,
        "davaciVekilAdres": davacivekiladdressController.text,
        "davaciAdi": firstNameController.text,
        "davaciSoyadi": lastNameController.text,
        "davaciTc": davaciTCNumasi.text,
        "davaciAdresi": addressController.text,
        "davaciIletisim": contactNumberController.text,
        "davaciMeslegi": professionController.text,
        "davaliVekilAdi": davalivekilfirstNameController.text,
        "davaliVekilSoyadi": davalivekillastNameController.text,
        "davaliVekilTc": davalivekilTCNumasi.text,
        "davaliVekilAdres": davalivekiladdressController.text,
        "davaliAdi": defendantFirstNameController.text,
        "davaliSoyadi": defendantLastNameController.text,
        "davaliTc": davaliTCNumasi.text,
        "davaliAdresi": defendantAddressController.text,
        "davaliIletisim": defendantContactNumberController.text,
        "davaliMeslegi": defendantProfessionController.text,
        "genelBilgiler": caseSubjectController.text,
        "count": selectedDaire.toString(),
        "baslamaTarihi": selectedDateTime!.toIso8601String(),
        "durusmaTarihi": selectedDateTimeDurusma!.toIso8601String(),
        "il": selectedCity.toString() == "Null" ? "" : selectedCity.toString(),
        "ilce": selectedDistrict.toString(),
        "gorevliMahkeme": selectedCourt.toString(),
        "mahkemeAsamasi": selectedAsama.toString(),
        "notlar": noteController.text,
      }),
    );
  }

  List<String> citiesilkderece = Lists.citiesilkderece;
  List<String> courtsilkderece = Lists.courtsilkderece;
  List<String> citiesbolgeidare = Lists.citiesbolgeidare;
  List<String> courtsbolgeidare = Lists.courtsbolgeidare;
  List<String> citiesbolgeadliye = Lists.citiesbolgeadliye;
  List<String> courtsbolgeadliye = Lists.courtsbolgeadliye;
  List<String> courtsyargitay = Lists.courtsyargitay;
  List<String> courtsdanistay = Lists.courtsdanistay;
  bool _isCheckedDavaciVekil = false; // Checkbox'ın başlangıç durumu
  bool _isCheckedDavaliVekil = false; // Checkbox'ın başlangıç durumu

  List<String> mahkemeAsama = [
    'İlk Derece Mahkemesi',
    'İstinaf-Bölge İdare Mahkemesi',
    'İstinaf-Bölge Adliye Mahkemeleri',
    'Temyiz-Yargıtay',
    'Temyiz-Danıştay',
    'Anayasa Mahkemesi',
    'Uyuşmazlık Mahkemesi',
  ];

  Future<bool> fetchDavalar() async {
    log(selectedCourt.toString());

    final response = await http
        .get(Uri.parse('https://bpv.tr/davalar/${Person.person.mail}'));

    if (response.statusCode == 200) {
      setState(() {
        var data = jsonDecode(response.body);
        Dava.davalar = Dava.listFromJson(data);
        // for (var dava in Dava.davalar) {
        //   Dava.selectedDates.add(dava.baslamaTarihi);
        // }
      });

      return true;
    }
    return false;
  }

  fetchilce(String sehiradi) async {
    // JSON dosyasını oku
    String jsonString = await rootBundle.loadString('assets/ilceler.json');

    // JSON verisini Dart nesnesine çevir
    List<dynamic> data = jsonDecode(jsonString);

    setState(() {
      ilceler = getIlcelerBySehirAdi(data, sehiradi);
    });

    print("Şehir: $sehiradi için ilçeler: $ilceler");
  }

  List<String> getIlcelerBySehirAdi(List<dynamic> data, String sehirAdi) {
    return data
        .where((item) =>
            _turkishToLower(item["sehir_adi"].toString()) ==
            _turkishToLower(sehirAdi)) // Türkçe'ye özel küçük harfe çevirme
        .map((item) =>
            item["ilce_adi"].toString()) // İlçe adlarını listeye ekleme
        .toList();
  }

// Türkçe karakterler için özel küçük harfe dönüştürme fonksiyonu
  String _turkishToLower(String input) {
    return input
        .replaceAll('I', 'ı')
        .replaceAll('İ', 'i')
        .replaceAll('Ğ', 'ğ')
        .replaceAll('Ü', 'ü')
        .replaceAll('Ş', 'ş')
        .replaceAll('Ö', 'ö')
        .replaceAll('Ç', 'ç')
        .replaceAll('Â', 'â')
        .replaceAll('Î', 'î')
        .toLowerCase(); // Genel küçük harf dönüşümünü uygulama
  }

  // Tarih Seçici Fonksiyonu
  Future<void> _selectDateTime(BuildContext context) async {
    // Tarih seçici
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8E1717),
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              timePickerTheme: const TimePickerThemeData(
                dialHandColor: Color(0xFF8E1717),
                dialBackgroundColor: Colors.black,
                dayPeriodTextColor: Colors.white,
                hourMinuteTextColor: Colors.white,
              ),
              dialogBackgroundColor: Colors.black,
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          startDateController.text =
              DateFormat('dd MMMM yyyy, HH:mm', 'tr').format(selectedDateTime!);
        });
      }
    }
  }

  //---------------------------------------------------------------------

  // Duruşma Tarihi Seçici Fonksiyonu
  Future<void> _selectdurusmaDateTime(BuildContext context) async {
    // Tarih seçici
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8E1717),
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              timePickerTheme: const TimePickerThemeData(
                dialHandColor: Color(0xFF8E1717),
                dialBackgroundColor: Colors.black,
                dayPeriodTextColor: Colors.white,
                hourMinuteTextColor: Colors.white,
              ),
              dialogBackgroundColor: Colors.black,
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTimeDurusma = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          durusmastartDateController.text =
              DateFormat('dd MMMM yyyy, HH:mm', 'tr')
                  .format(selectedDateTimeDurusma!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('tr', null); // Türkçe tarih formatı

    // 1'den 50'ye kadar bir liste oluşturuyoruz

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 52),
              Text(
                'Yeni Kayıt',
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey, // Form anahtarı
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dava No
                    TextFormField(
                      controller: fileNumberController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Dosya No/Esas No',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Dosya No gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Davacı Bilgileri başlığı
                    Text(
                      'Davacı Bilgileri',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Davacı Adı
                    TextFormField(
                      controller: firstNameController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Adı',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Adı gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Davacı Soyadı
                    TextFormField(
                      controller: lastNameController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Soyadı',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Soyadı gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: davaciTCNumasi,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'T.C. Numarası',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType
                          .number, // Sadece rakam girişi için numara klavyesi
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Sadece rakamlara izin ver
                        LengthLimitingTextInputFormatter(
                            11), // Maksimum 11 karakter
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'T.C. Numarası gerekli';
                        }
                        // T.C. kimlik numarasının 11 haneli olup olmadığını kontrol et
                        else if (value.length != 11) {
                          return 'Geçersiz T.C. Numarası';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Davacı Adresi
                    TextFormField(
                      controller: addressController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Adresi',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Adresi gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Davacı İletişim Numarası

                    TextFormField(
                      controller: contactNumberController,
                      inputFormatters: [maskFormatter], // Maskeyi ekliyoruz
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'İletişim Numarası',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        // Maskesiz ham değeri alıyoruz
                        String unmaskedValue = maskFormatter.getUnmaskedText();

                        if (unmaskedValue.isEmpty) {
                          return 'İletişim Numarası gerekli';
                        }
                        // Format kontrolü (Türkiye telefon numarası)
                        else if (!RegExp(r'^\d{10}$').hasMatch(unmaskedValue)) {
                          return 'Geçersiz Türkiye telefon numarası';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Davacı Mesleği
                    TextFormField(
                      controller: professionController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Mesleği',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mesleği gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isCheckedDavaciVekil,
                          onChanged: (bool? value) {
                            setState(() {
                              _isCheckedDavaciVekil =
                                  value!; // Checkbox durumu güncelleniyor
                            });
                          },
                        ),
                        Text(
                          'Vekil Var',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                    if (_isCheckedDavaciVekil)
                      TextFormField(
                        controller: davacivekilfirstNameController,
                        style: GoogleFonts.merriweather(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Vekilin Adı',
                          labelStyle:
                              GoogleFonts.merriweather(color: Colors.white),
                          filled: true,
                          fillColor: const Color(0xFF252525),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF8E1717), // Aktif alan rengi
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          return null;
                        },
                      ),
                    if (_isCheckedDavaciVekil) 
                    const SizedBox(height: 16),
                    if (_isCheckedDavaciVekil)
                      TextFormField(
                        controller: davacivekillastNameController,
                        style: GoogleFonts.merriweather(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Vekilin Soyadı',
                          labelStyle:
                              GoogleFonts.merriweather(color: Colors.white),
                          filled: true,
                          fillColor: const Color(0xFF252525),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF8E1717), // Aktif alan rengi
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          return null;
                        },
                      ),
                    if (_isCheckedDavaciVekil)
                    const SizedBox(height: 16),
                    if (_isCheckedDavaciVekil)
                      TextFormField(
                        controller: davacivekiladdressController,
                        style: GoogleFonts.merriweather(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Adresi',
                          labelStyle:
                              GoogleFonts.merriweather(color: Colors.white),
                          filled: true,
                          fillColor: const Color(0xFF252525),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF8E1717), // Aktif alan rengi
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        validator: (value) {
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    if (_isCheckedDavaciVekil)
                      TextFormField(
                        controller: davacivekilTCNumasi,
                        style: GoogleFonts.merriweather(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'T.C. Numarası',
                          labelStyle:
                              GoogleFonts.merriweather(color: Colors.white),
                          filled: true,
                          fillColor: const Color(0xFF252525),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF8E1717), // Aktif alan rengi
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        keyboardType: TextInputType
                            .number, // Sadece rakam girişi için numara klavyesi
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Sadece rakamlara izin ver
                          LengthLimitingTextInputFormatter(
                              11), // Maksimum 11 karakter
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            //return 'T.C. Numarası gerekli';
                          }
                          // T.C. kimlik numarasının 11 haneli olup olmadığını kontrol et
                          else if (value.length != 11) {
                            return 'Geçersiz T.C. Numarası';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 24),

                    // Davalı Bilgileri başlığı
                    Text(
                      'Davalı Bilgileri',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Davalı Adı
                    TextFormField(
                      controller: defendantFirstNameController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Adı',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Adı gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Davalı Soyadı
                    TextFormField(
                      controller: defendantLastNameController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Soyadı',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Soyadı gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: davaliTCNumasi,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'T.C. Numarası',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType
                          .number, // Sadece rakam girişi için numara klavyesi
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Sadece rakamlara izin ver
                        LengthLimitingTextInputFormatter(
                            11), // Maksimum 11 karakter
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'T.C. Numarası gerekli';
                        }
                        // T.C. kimlik numarasının 11 haneli olup olmadığını kontrol et
                        else if (value.length != 11) {
                          return 'Geçersiz T.C. Numarası';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Davalı Adresi
                    TextFormField(
                      controller: defendantAddressController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Adresi',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Adresi gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Davalı İletişim Numarası
                    TextFormField(
                      controller: defendantContactNumberController,
                      inputFormatters: [
                        defendantMaskFormatter
                      ], // Maskeyi burada kullanıyoruz
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'İletişim Numarası',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        // Maskesiz ham değeri alıyoruz
                        String unmaskedValue =
                            defendantMaskFormatter.getUnmaskedText();

                        if (unmaskedValue.isEmpty) {
                          return 'İletişim Numarası gerekli';
                        }
                        // 10 haneli telefon numarası kontrolü
                        else if (!RegExp(r'^\d{10}$').hasMatch(unmaskedValue)) {
                          return 'Geçersiz Türkiye telefon numarası';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Davalı Mesleği
                    TextFormField(
                      controller: defendantProfessionController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Mesleği',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mesleği gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isCheckedDavaliVekil,
                          onChanged: (bool? value) {
                            setState(() {
                              _isCheckedDavaliVekil =
                                  value!; // Checkbox durumu güncelleniyor
                            });
                          },
                        ),
                        Text(
                          'Vekil Var',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                    if(_isCheckedDavaliVekil)
                    TextFormField(
                      controller: davalivekilfirstNameController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Vekilin Adı',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    if(_isCheckedDavaliVekil)

                    const SizedBox(height: 16),
                    if(_isCheckedDavaliVekil)

                    TextFormField(
                      controller: davalivekillastNameController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Vekilin Soyadı',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    if(_isCheckedDavaliVekil)

                    const SizedBox(height: 16),
                    if(_isCheckedDavaliVekil)

                    TextFormField(
                      controller: davalivekiladdressController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Adresi',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      validator: (value) {
                        return null;
                      },
                    ),
                    if(_isCheckedDavaliVekil)

                    const SizedBox(height: 16),
                    if(_isCheckedDavaliVekil)

                    TextFormField(
                      controller: davalivekilTCNumasi,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'T.C. Numarası',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType
                          .number, // Sadece rakam girişi için numara klavyesi
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Sadece rakamlara izin ver
                        LengthLimitingTextInputFormatter(
                            11), // Maksimum 11 karakter
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          //return 'T.C. Numarası gerekli';
                        }
                        // T.C. kimlik numarasının 11 haneli olup olmadığını kontrol et
                        else if (value.length != 11) {
                          return 'Geçersiz T.C. Numarası';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    const SizedBox(height: 16),

                    Text(
                      'Dava Başlama Tarihi',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: startDateController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      readOnly: true,
                      onTap: () => _selectDateTime(context),
                      decoration: InputDecoration(
                        labelText: 'Tarih ve Saat Seçin',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ), // Takvim ikonu
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir tarih ve saat seçin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Genel Bilgiler başlığı
                    Text(
                      'Dava Konusu',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Davaya İlişkin Konu (Text Area)
                    TextFormField(
                      controller: caseSubjectController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Davaya İlişkin Konu',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bu alan gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ' Mahkeme Aşaması',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownSearch<String>(
                      items: mahkemeAsama, // Mahkemeler listesi
                      selectedItem: selectedAsama,
                      onChanged: (value) {
                        setState(() {
                          selectedAsama = value;
                        });
                      },
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(
                              0xFF252525), // TextBox arka planı koyu renk
                          labelText: " Mahkeme Aşaması",
                          labelStyle: GoogleFonts.merriweather(
                              color:
                                  Colors.white), // TextBox içindeki yazı beyaz
                          hintStyle: GoogleFonts.merriweather(
                              color: Colors.white), // Seçim sonrası yazı beyaz
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        baseStyle: GoogleFonts.merriweather(
                            color: Colors.white), // Seçim sonrası beyaz yazı
                      ),
                      popupProps: PopupProps.dialog(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          style: GoogleFonts.merriweather(
                              color: Colors.white), // Arama yazı rengi beyaz
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(
                                0xFF252525), // Arama alanı koyu renk
                            labelText: 'Ara...',
                            labelStyle: GoogleFonts.merriweather(
                                color:
                                    Colors.white), // Arama kutusu etiketi beyaz
                          ),
                        ),
                        containerBuilder: (ctx, popupWidget) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black, // Popup arka plan rengi koyu
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: popupWidget,
                          );
                        },
                        itemBuilder: (context, item, isSelected) {
                          return ListTile(
                            tileColor: isSelected
                                ? const Color(0xFF8E1717)
                                : Colors
                                    .black, // Seçilen ve diğer öğelerin arka plan rengi
                            title: Text(
                              item,
                              style: GoogleFonts.merriweather(
                                  color: Colors
                                      .white), // Açılan öğe yazı rengi beyaz
                            ),
                          );
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir mahkeme seçiniz.'; // Boş değerler için hata mesajı
                        }
                        return null; // Geçerli ise hata mesajı yok
                      },
                    ),
                    if (selectedAsama == "İlk Derece Mahkemesi")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'İl Seçimi',
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownSearch<String>(
                            items: citiesilkderece, // Şehirler listesi
                            selectedItem: selectedCity,
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value;
                              });
                              if (value != null) {
                                fetchilce(
                                    value); // Seçili şehre göre ilçeleri getir
                              }
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "İl Seçimi",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item,
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir şehir seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),

                          // İl Seçimi (Dropdown Search)
                          Text(
                            'İlçe Seçimi',
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownSearch<String>(
                            items: ilceler, // Şehirler listesi
                            selectedItem: selectedDistrict,
                            onChanged: (value) {
                              setState(() {
                                selectedDistrict = value;
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "İlçe Seçimi",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item,
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir ilçe seçiniz.'; // Boş değerler için hata mesajı
                              }

                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),
                          Text('Kaçıncı Mahkeme',
                              style: GoogleFonts.merriweather(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          DropdownSearch<int>(
                            items: List<int>.generate(51,
                                (index) => index), // 0-50 arasındaki sayılar
                            selectedItem:
                                selectedDaire, // Seçilen sayıyı buradan kontrol edeceksin
                            onChanged: (value) {
                              setState(() {
                                selectedDaire = value;
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "Sayı Seçimi",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item.toString(),
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Lütfen bir sayı seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),

                          // Görevli Mahkeme Seçimi (Dropdown Search)
                          Text(
                            'Görevli Mahkeme',
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownSearch<String>(
                            items: courtsilkderece, // Mahkemeler listesi
                            selectedItem: selectedCourt,
                            onChanged: (value) {
                              setState(() {
                                selectedCourt = value;
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "Görevli Mahkeme",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item,
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir mahkeme seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    if (selectedAsama == "İstinaf-Bölge İdare Mahkemesi")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'İl Seçimi',
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownSearch<String>(
                            items: citiesbolgeidare, // Şehirler listesi
                            selectedItem: selectedCity,
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value;
                              });
                              if (value != null) {}
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "İl Seçimi",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item,
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir şehir seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),

                          // İl Seçimi (Dropdown Search)

                          const SizedBox(height: 16),
                          Text('Kaçıncı Daire',
                              style: GoogleFonts.merriweather(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          DropdownSearch<int>(
                            items: List<int>.generate(21,
                                (index) => index), // 0-50 arasındaki sayılar
                            selectedItem:
                                selectedDaire, // Seçilen sayıyı buradan kontrol edeceksin
                            onChanged: (value) {
                              setState(() {
                                selectedDaire =
                                    value; // Seçilen sayıyı güncelle
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "Daire Seçimi",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item.toString(),
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Lütfen bir sayı seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),

                          // Görevli Mahkeme Seçimi (Dropdown Search)
                          Text(
                            'Hangi Daire',
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownSearch<String>(
                            items: courtsbolgeidare, // Mahkemeler listesi
                            selectedItem: selectedCourt,
                            onChanged: (value) {
                              setState(() {
                                selectedCourt = value;
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "Hangi Daire",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item,
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir mahkeme seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    if (selectedAsama == "İstinaf-Bölge Adliye Mahkemeleri")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'İl Seçimi',
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownSearch<String>(
                            items: citiesbolgeadliye, // Şehirler listesi
                            selectedItem: selectedCity,
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value;
                              });
                              if (value != null) {}
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "İl Seçimi",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item,
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir şehir seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),

                          // İl Seçimi (Dropdown Search)

                          const SizedBox(height: 16),
                          Text('Kaçıncı Daire',
                              style: GoogleFonts.merriweather(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          DropdownSearch<int>(
                            items: List<int>.generate(101,
                                (index) => index), // 0-50 arasındaki sayılar
                            selectedItem:
                                selectedDaire, // Seçilen sayıyı buradan kontrol edeceksin
                            onChanged: (value) {
                              setState(() {
                                selectedDaire =
                                    value; // Seçilen sayıyı güncelle
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "Daire Seçimi",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item.toString(),
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Lütfen bir sayı seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),

                          // Görevli Mahkeme Seçimi (Dropdown Search)
                          Text(
                            'Hangi Daire',
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownSearch<String>(
                            items: courtsbolgeadliye, // Mahkemeler listesi
                            selectedItem: selectedCourt,
                            onChanged: (value) {
                              setState(() {
                                selectedCourt = value;
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "Görevli Daire",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item,
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir mahkeme seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    if (selectedAsama == "Temyiz-Yargıtay")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Görevli Mahkeme',
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownSearch<String>(
                            items: courtsyargitay, // Mahkemeler listesi
                            selectedItem: selectedCourt,
                            onChanged: (value) {
                              setState(() {
                                selectedCourt = value;
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "Görevli Mahkeme",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item,
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir mahkeme seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    if (selectedAsama == "Temyiz-Danıştay")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // İl Seçimi (Dropdown Search)

                          // Görevli Mahkeme Seçimi (Dropdown Search)
                          Text(
                            'Görevli Mahkeme',
                            style: GoogleFonts.merriweather(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownSearch<String>(
                            items: courtsdanistay, // Mahkemeler listesi
                            selectedItem: selectedCourt,
                            onChanged: (value) {
                              setState(() {
                                selectedCourt = value;
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(
                                    0xFF252525), // TextBox arka planı koyu renk
                                labelText: "Görevli Mahkeme",
                                labelStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // TextBox içindeki yazı beyaz
                                hintStyle: GoogleFonts.merriweather(
                                    color: Colors
                                        .white), // Seçim sonrası yazı beyaz
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              baseStyle: GoogleFonts.merriweather(
                                  color:
                                      Colors.white), // Seçim sonrası beyaz yazı
                            ),
                            popupProps: PopupProps.dialog(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                style: GoogleFonts.merriweather(
                                    color:
                                        Colors.white), // Arama yazı rengi beyaz
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(
                                      0xFF252525), // Arama alanı koyu renk
                                  labelText: 'Ara...',
                                  labelStyle: GoogleFonts.merriweather(
                                      color: Colors
                                          .white), // Arama kutusu etiketi beyaz
                                ),
                              ),
                              containerBuilder: (ctx, popupWidget) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .black, // Popup arka plan rengi koyu
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: popupWidget,
                                );
                              },
                              itemBuilder: (context, item, isSelected) {
                                return ListTile(
                                  tileColor: isSelected
                                      ? const Color(0xFF8E1717)
                                      : Colors
                                          .black, // Seçilen ve diğer öğelerin arka plan rengi
                                  title: Text(
                                    item,
                                    style: GoogleFonts.merriweather(
                                        color: Colors
                                            .white), // Açılan öğe yazı rengi beyaz
                                  ),
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen bir mahkeme seçiniz.'; // Boş değerler için hata mesajı
                              }
                              return null; // Geçerli ise hata mesajı yok
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    const SizedBox(height: 16),

                    Text(
                      'Duruşma Tarihi',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: durusmastartDateController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      readOnly: true,
                      onTap: () => _selectdurusmaDateTime(context),
                      decoration: InputDecoration(
                        labelText: 'Tarih ve Saat Seçin',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF8E1717), // Aktif alan rengi
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ), // Takvim ikonu
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen bir tarih ve saat seçin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dava Aşaması (Dropdown Search)
                    // y
                    // Notlar (Text Area)
                    Text(
                      'Notlar',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: noteController,
                      style: GoogleFonts.merriweather(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Notlar',
                        labelStyle:
                            GoogleFonts.merriweather(color: Colors.white),
                        filled: true,
                        fillColor: const Color(0xFF252525),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Kaydet butonu
                    SizedBox(
                      width: double
                          .infinity, // Buton genişliği tüm form genişliği kadar olacak
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await createDava();
                            await fetchDavalar();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Kayıt başarıyla tamamlandı!')),
                            );

                            // Kayıt başarılıysa SavedPage'e yönlendir
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         SavedPage(), // Kaydedilenler sayfası
                            //   ),
                            // );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF8E1717), // Buton rengi
                          padding: const EdgeInsets.symmetric(
                              vertical: 16), // Buton yüksekliği
                        ),
                        child: Text(
                          'Kaydet',
                          style: GoogleFonts.merriweather(
                              fontSize: 18,
                              color: Colors.white), // Buton yazısı beyaz olacak
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent, // Splash rengi kaldırıldı
          highlightColor: Colors.transparent, // Highlight rengi kaldırıldı
          hoverColor: Colors.transparent, // Hover rengi kaldırıldı
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF252525),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
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
              icon: ImageIcon(AssetImage('assets/new-activate-icon.png')),
              label: 'Yeni',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/calendar-line-icon.png')),
              label: 'Takvim',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/profile-line-icon.png')),
              label: 'Profil',
            ),
          ],
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedPage()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage()),
              );
            } else if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            }
          },
        ),
      ),
    );
  }
}
