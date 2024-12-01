import 'package:flutter/material.dart';
import 'package:katip/entity/davalar.dart'; // Dava modelini import ediyoruz
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'package:katip/update.dart';
import 'package:http/http.dart' as http;
import 'package:katip/saved.dart'; // Silme işleminden sonra yönlendirme için
import 'package:url_launcher/url_launcher.dart';

class EntryPage extends StatefulWidget  {
  final Dava dava; // Tıklanan kayda ait dava bilgisi

  EntryPage({required this.dava}); // Constructor ile dava bilgisini alıyoruz
 _EntryPageState createState() => _EntryPageState();
}

 class _EntryPageState extends State<EntryPage> {
  // UYAP web sayfasına yönlendirmek için fonksiyon
  Future<void> _launchUYAP() async {
    const url = 'https://avukat.uyap.gov.tr/main/avukat/index.jsp?v=3784';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'URL açılamıyor: $url';
    }
  }

  // Dava silme fonksiyonu

    Future<void> deleteDavalar(String id) async {
    final url = Uri.parse(
        'https://bpv.tr/davalar/$id'); // Doğru URL olduğundan emin olun
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          Dava.davalar.removeWhere((dava) => dava.id.toString() == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dava başarıyla silindi.')),
        );
      } else {
        print('Silme işlemi başarısız: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Silme hatası: ${response.body}')),
        );
      }
    } catch (e) {
      print('Bağlantı hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlantı hatası: $e')),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dava Detayları',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF060606),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFF060606),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Esas No: ${widget.dava.esasNo}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Davacı Bilgileri',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Adı: ${widget.dava.davaciAdi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Soyadı: ${widget.dava.davaciSoyadi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('T.C.: ${widget.dava.davaciTc}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Adresi: ${widget.dava.davaciAdresi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('İletişim: ${widget.dava.davaciIletisim}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Mesleği: ${widget.dava.davaciMeslegi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Vekil Adı: ${widget.dava.davaciVekilAdi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Vekil Soyadı: ${widget.dava.davaciVekilSoyadi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Vekil T.C.: ${widget.dava.davaciVekilTc}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Vekil Adresi: ${widget.dava.davaciVekilAdres}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Davalı Bilgileri',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Adı: ${widget.dava.davaliAdi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Soyadı: ${widget.dava.davaliSoyadi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('T.C.: ${widget.dava.davaliTc}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Adresi: ${widget.dava.davaliAdresi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('İletişim: ${widget.dava.davaliIletisim}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Mesleği: ${widget.dava.davaliMeslegi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Vekil Adı: ${widget.dava.davaliVekilAdi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Vekil Soyadı: ${widget.dava.davaliVekilSoyadi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Vekil T.C.: ${widget.dava.davaliVekilTc}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                        Text('Vekil Adresi: ${widget.dava.davaliVekilAdres}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genel Bilgiler',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Genel Bilgiler: ${widget.dava.genelBilgiler}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                            if(widget.dava.il!="null")
                        Text('İl: ${widget.dava.il}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                            if(widget.dava.ilce!="null")

                        Text('İlçe: ${widget.dava.ilce}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                            if(widget.dava.gorevliMahkeme!="null")
                            
                        Text('Görevli Mahkeme: ${widget.dava.gorevliMahkeme}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                            if(widget.dava.mahkemeAsamasi!="null")

                        Text('Dava Aşaması: ${widget.dava.mahkemeAsamasi}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                            if(widget.dava.notlar!="null")

                        Text('Notlar: ${widget.dava.notlar}',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dava Tarihi',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Başlama Tarihi: ${DateFormat('dd.MM.yyyy').format(widget.dava.baslamaTarihi)}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          'Duruşma Tarihi: ${DateFormat('dd.MM.yyyy').format(widget.dava.durusmaTarihi)}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdatePage(dava: widget.dava),
                                ),
                              );
                            },
                            child: Center(
                              child: Text(
                                "Güncelle",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.red,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              side: BorderSide(
                                color: Colors.red,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _launchUYAP,
                            child: Center(
                              child: Text(
                                "UYAP",
                                style: TextStyle(color: Color(0xFF111111)),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8E1717),
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Color(0xFF060606),
                                    title: Text(
                                      'Sil',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      'Bu davayı silmek istediğinize emin misiniz?',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text(
                                          'Hayır',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text(
                                          'Evet',
                                          style: TextStyle(color: Color(0xFF8E1717)),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (shouldDelete == true) {
                                await deleteDavalar(widget.dava.id.toString());
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SavedPage()),
                                );
                              }
                            },
                            child: Center(
                              child: Text(
                                "Kaydı Sil",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.red,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              side: BorderSide(
                                color: Colors.red,
                                width: 1.0,
                              ),
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
        ],
      ),
    );
  }
}
