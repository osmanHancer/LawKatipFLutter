import 'dart:convert'; // JSON işlemleri için
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP istekleri için
import 'package:katip/entity/davalar.dart';
import 'package:katip/entity/person.dart';
import 'package:katip/saved.dart'; // Dava sınıfını içe aktarıyoruz
import 'package:google_fonts/google_fonts.dart'; // Yazı tipleri için

class UpdatePage extends StatefulWidget {
  final Dava dava; // Güncellenecek dava bilgileri

  const UpdatePage({super.key, required this.dava});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  // Tarih ve saat seçimi için gerekli değişkenler
  DateTime? selectedStartDateTime; // Seçilen başlama tarihi
  DateTime? selectedHearingDateTime; // Seçilen duruşma tarihi

  final TextEditingController startDateController = TextEditingController(); // Başlama tarihi controller
  final TextEditingController hearingDateController = TextEditingController(); // Duruşma tarihi controller

  @override
  void initState() {
    super.initState();
    // Başlangıç ve duruşma tarihlerini var olan verilerle başlatıyoruz
    startDateController.text =
    "${widget.dava.baslamaTarihi.day}/${widget.dava.baslamaTarihi.month}/${widget.dava.baslamaTarihi.year}";
    hearingDateController.text =
    "${widget.dava.durusmaTarihi.day}/${widget.dava.durusmaTarihi.month}/${widget.dava.durusmaTarihi.year}";
  }

  // Başlama tarihi seçici
  Future<void> _selectStartDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6D4700),
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
      setState(() {
        selectedStartDateTime = pickedDate;
        startDateController.text =
        "${selectedStartDateTime!.day}/${selectedStartDateTime!.month}/${selectedStartDateTime!.year}";
      });
    }
  }

  // Duruşma tarihi seçici
  Future<void> _selectHearingDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedHearingDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6D4700),
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
      setState(() {
        selectedHearingDateTime = pickedDate;
        hearingDateController.text =
        "${selectedHearingDateTime!.day}/${selectedHearingDateTime!.month}/${selectedHearingDateTime!.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController dosyaNoController =
    TextEditingController(text: widget.dava.esasNo);
    final TextEditingController davaciAdiController =
    TextEditingController(text: widget.dava.davaciAdi);
    final TextEditingController davaciSoyadiController =
    TextEditingController(text: widget.dava.davaciSoyadi);
    final TextEditingController davaciTcController =
    TextEditingController(text: widget.dava.davaciTc); // Davacı TC eklendi
    final TextEditingController davaciAdresiController =
    TextEditingController(text: widget.dava.davaciAdresi);
    final TextEditingController davaciIletisimController =
    TextEditingController(text: widget.dava.davaciIletisim);
    final TextEditingController davaciMeslegiController =
    TextEditingController(text: widget.dava.davaciMeslegi);
    final TextEditingController davaciVekilAdiController =
    TextEditingController(text: widget.dava.davaciVekilAdi);
    final TextEditingController davaciVekilSoyadiController =
    TextEditingController(text: widget.dava.davaciVekilSoyadi);
    final TextEditingController davaciVekilTcController =
    TextEditingController(text: widget.dava.davaciVekilTc);
    final TextEditingController davaciVekilAdresController =
    TextEditingController(text: widget.dava.davaciVekilAdres);
    final TextEditingController countmahkeme =
    TextEditingController(text: widget.dava.count);

    final TextEditingController davaliAdiController =
    TextEditingController(text: widget.dava.davaliAdi);
    final TextEditingController davaliSoyadiController =
    TextEditingController(text: widget.dava.davaliSoyadi);
    final TextEditingController davaliTcController =
    TextEditingController(text: widget.dava.davaliTc); // Davalı TC eklendi
    final TextEditingController davaliAdresiController =
    TextEditingController(text: widget.dava.davaliAdresi);
    final TextEditingController davaliIletisimController =
    TextEditingController(text: widget.dava.davaliIletisim);
    final TextEditingController davaliMeslegiController =
    TextEditingController(text: widget.dava.davaliMeslegi);
    final TextEditingController davaliVekilAdiController =
    TextEditingController(text: widget.dava.davaliVekilAdi);
    final TextEditingController davaliVekilSoyadiController =
    TextEditingController(text: widget.dava.davaliVekilSoyadi);
    final TextEditingController davaliVekilTcController =
    TextEditingController(text: widget.dava.davaliVekilTc);
    final TextEditingController davaliVekilAdresController =
    TextEditingController(text: widget.dava.davaliVekilAdres);

    final TextEditingController genelBilgilerController =
    TextEditingController(text: widget.dava.genelBilgiler);
    final TextEditingController ilController =
    TextEditingController(text: widget.dava.il);
    final TextEditingController ilceController =
    TextEditingController(text: widget.dava.ilce); // İlçe alanı eklendi
    final TextEditingController gorevliMahkemeController =
    TextEditingController(text: widget.dava.gorevliMahkeme);
    final TextEditingController davaAsamasiController =
    TextEditingController(text: widget.dava.mahkemeAsamasi);
    final TextEditingController notlarController =
    TextEditingController(text: widget.dava.notlar);

    Future<bool> fetchDavalar() async {
      final response = await http
          .get(Uri.parse('https://bpv.tr/davalar/${Person.person.mail}'));

      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body);
          Dava.davalar = Dava.listFromJson(data);
        });

        return true;
      }
      return false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dava Güncelle',
            style: GoogleFonts.merriweather(fontSize: 17, color: Colors.white)),
        backgroundColor: Color(0xFF060606),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Color(0xFF060606),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: dosyaNoController,
                decoration: InputDecoration(
                  labelText: 'Dosya No',
                  labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF252525),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF8E1717), // Aktif alan rengi
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildTextSection(
                  'Davacı Bilgileri',
                  davaciAdiController,
                  davaciSoyadiController,
                  davaciTcController, // Davacı TC alanı eklendi
                  davaciAdresiController,
                  davaciIletisimController,
                  davaciMeslegiController),
              const SizedBox(height: 16),
              _buildVekilSection('Davacı Vekil Bilgileri', davaciVekilAdiController, davaciVekilSoyadiController, davaciVekilTcController, davaciVekilAdresController),
              const SizedBox(height: 16),
              Text(
                'Dava Başlama Tarihi',
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 17, // 1 punto düşürüldü
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: startDateController,
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
                readOnly: true,
                onTap: () => _selectStartDateTime(context),
                decoration: InputDecoration(
                  labelText: 'Başlama Tarihini Seçin',
                  labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
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
                    return 'Lütfen bir tarih seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Duruşma Tarihi',
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 17, // 1 punto düşürüldü
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: hearingDateController,
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
                readOnly: true,
                onTap: () => _selectHearingDateTime(context),
                decoration: InputDecoration(
                  labelText: 'Duruşma Tarihini Seçin',
                  labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
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
                    return 'Lütfen bir tarih seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextSection(
                  'Davalı Bilgileri', davaliAdiController, davaliSoyadiController, davaliTcController, davaliAdresiController, davaliIletisimController, davaliMeslegiController),
              const SizedBox(height: 16),
              _buildVekilSection('Davalı Vekil Bilgileri', davaliVekilAdiController, davaliVekilSoyadiController, davaliVekilTcController, davaliVekilAdresController),
              const SizedBox(height: 16),
              TextField(
                controller: genelBilgilerController,
                decoration: InputDecoration(
                    labelText: 'Genel Bilgiler',
                    labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF252525)),
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
              ),
              if(ilController.text!="null")
              TextField(
                controller: ilController,
                decoration: InputDecoration(
                    labelText: 'İl',
                    labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF252525)),
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
              ),
              if(ilceController.text!="null")
              TextField(
                controller: ilceController, // İlçe alanı eklendi
                decoration: InputDecoration(
                    labelText: 'İlçe',
                    labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF252525)),
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
              ),
              if(gorevliMahkemeController.text!="null")
              
              TextField(
                controller: gorevliMahkemeController,
                decoration: InputDecoration(
                    labelText: 'Görevli Mahkeme',
                    labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF252525)),
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
              ),

              TextField(
                controller: davaAsamasiController,
                decoration: InputDecoration(
                    labelText: 'Dava Aşaması',
                    labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF252525)),
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
              ),
              if(countmahkeme.text!="null")
              TextField(
                controller: countmahkeme,
                decoration: InputDecoration(
                    labelText: 'Kaçıncı Mahkeme',
                    labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF252525)),
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
              ),
              TextField(
                controller: notlarController,
                decoration: InputDecoration(
                    labelText: 'Notlar',
                    labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF252525)),
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8E1717), // Buton rengi
                  ),
                  onPressed: () async {
                    final response = await http.patch(
                      Uri.parse(
                          'https://bpv.tr/davalar/${widget.dava.id}'), // Güncelleme isteği
                      headers: {
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode({
                        'esasNo': dosyaNoController.text,
                        'baslamaTarihi': selectedStartDateTime?.toIso8601String() ??
                            widget.dava.baslamaTarihi.toIso8601String(),
                        'durusmaTarihi': selectedHearingDateTime?.toIso8601String() ??
                            widget.dava.durusmaTarihi.toIso8601String(),
                        'mail': widget.dava.mail,
                        'davaciAdi': davaciAdiController.text,
                        'davaciSoyadi': davaciSoyadiController.text,
                        'davaciTc': davaciTcController.text,
                        'davaciAdresi': davaciAdresiController.text,
                        'davaciIletisim': davaciIletisimController.text,
                        'davaciMeslegi': davaciMeslegiController.text,
                        'davaciVekilAdi': davaciVekilAdiController.text,
                        'davaciVekilSoyadi': davaciVekilSoyadiController.text,
                        'davaciVekilTc': davaciVekilTcController.text,
                        'davaciVekilAdres': davaciVekilAdresController.text,
                        'davaliAdi': davaliAdiController.text,
                        'davaliSoyadi': davaliSoyadiController.text,
                        'davaliTc': davaliTcController.text,
                        'davaliAdresi': davaliAdresiController.text,
                        'davaliIletisim': davaliIletisimController.text,
                        'davaliMeslegi': davaliMeslegiController.text,
                        'davaliVekilAdi': davaliVekilAdiController.text,
                        'davaliVekilSoyadi': davaliVekilSoyadiController.text,
                        'davaliVekilTc': davaliVekilTcController.text,
                        'davaliVekilAdres': davaliVekilAdresController.text,
                        'genelBilgiler': genelBilgilerController.text,
                        'il': ilController.text,
                        'ilce': ilceController.text, // İlçe alanı eklendi
                        'gorevliMahkeme': gorevliMahkemeController.text,
                        'davaAsamasi': davaAsamasiController.text,
                        'notlar': notlarController.text,
                      }),
                    );
                    if (response.statusCode == 200) {
                      // Başarılı güncelleme
                      print('Dava bilgileri güncellendi.');
                      await fetchDavalar();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SavedPage()), // Kaydedilenler sayfası
                      );
                    } else {
                      print('Güncelleme hatası: ${response.statusCode}');
                      print('Yanıt: ${response.body}');
                    }
                  },
                  child: Text('Güncelle', style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Yardımcı metotlar
  Widget _buildTextSection(
      String title,
      TextEditingController adiController,
      TextEditingController soyadiController,
      TextEditingController tcController, // TC numarası eklendi
      TextEditingController adresController,
      TextEditingController iletisimController,
      TextEditingController meslekController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.merriweather(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        TextField(
          controller: adiController,
          decoration: InputDecoration(
            labelText: '$title Adı',
            labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            filled: true,
            fillColor: Color(0xFF252525),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF8E1717), // Aktif alan rengi
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
        ),
        TextField(
          controller: soyadiController,
          decoration: InputDecoration(
            labelText: '$title Soyadı',
            labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            filled: true,
            fillColor: Color(0xFF252525),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF8E1717), // Aktif alan rengi
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
        ),
        TextField(
          controller: tcController, // TC numarası alanı
          decoration: InputDecoration(
            labelText: '$title TC',
            labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            filled: true,
            fillColor: Color(0xFF252525),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF8E1717), // Aktif alan rengi
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
        ),
        TextField(
          controller: adresController,
          decoration: InputDecoration(
            labelText: '$title Adresi',
            labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            filled: true,
            fillColor: Color(0xFF252525),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF8E1717), // Aktif alan rengi
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
        ),
        TextField(
          controller: iletisimController,
          decoration: InputDecoration(
            labelText: '$title İletişim',
            labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            filled: true,
            fillColor: Color(0xFF252525),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF8E1717), // Aktif alan rengi
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
        ),
        TextField(
          controller: meslekController,
          decoration: InputDecoration(
            labelText: '$title Mesleği',
            labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            filled: true,
            fillColor: Color(0xFF252525),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF8E1717), // Aktif alan rengi
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildVekilSection(
      String title,
      TextEditingController vekilAdiController,
      TextEditingController vekilSoyadiController,
      TextEditingController vekilTcController,
      TextEditingController vekilAdresController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.merriweather(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        TextField(
          controller: vekilAdiController,
          decoration: InputDecoration(
            labelText: '$title Adı',
            labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            filled: true,
            fillColor: Color(0xFF252525),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF8E1717), // Aktif alan rengi
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
        ),
        TextField(
          controller: vekilSoyadiController,
          decoration: InputDecoration(
            labelText: '$title Soyadı',
            labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            filled: true,
            fillColor: Color(0xFF252525),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF8E1717), // Aktif alan rengi
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
        ),
        TextField(
          controller: vekilTcController,
          decoration: InputDecoration(
            labelText: '$title TC',
            labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            filled: true,
            fillColor: Color(0xFF252525),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF8E1717), // Aktif alan rengi
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
        ),
        TextField(
          controller: vekilAdresController,
          decoration: InputDecoration(
            labelText: '$title Adresi',
            labelStyle: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
            filled: true,
            fillColor: Color(0xFF252525),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF8E1717), // Aktif alan rengi
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white),
        ),
      ],
    );
  }
}
