import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için import
import 'package:katip/calendar.dart';
import 'package:katip/profile.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts paketi
import 'home.dart'; // Ana Sayfa için gerekli import
import 'new.dart'; // NewRegistrationPage sınıfı için import
import 'package:http/http.dart' as http; // HTTP paketini ekliyoruz
import 'package:katip/entity/davalar.dart'; // Dava sınıfını kullanmak için import
import 'package:katip/update.dart';
import 'package:katip/entry.dart'; // EntryPage import

class SavedPage extends StatefulWidget {
  final DateTime? selectedDate; // Seçilen tarihi alacak

  SavedPage({this.selectedDate}); // Yapıcı fonksiyon

  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  int _selectedIndex =
      1; // Kaydedilenler sayfası aktif olduğu için başlangıç değeri 1
  List<Dava> davalar = []; // Dava bilgilerini dinamik tutmak için liste
  List<Dava> filteredDavalar = []; // Arama sonrası filtrelenmiş dava listesi
  bool isLoading =
      true; // Veriler yüklenirken gösterilecek olan yükleme göstergesi
  String searchQuery = ""; // Arama sorgusu
  DateTime? selectedStartDate; // Seçilen başlangıç tarihi

  @override
  void initState() {
    super.initState();
    _fetchDavalar(); // API'den davaları çekiyoruz
    if (widget.selectedDate != null) {
      selectedStartDate = widget
          .selectedDate; // Takvimden seçilen tarihi başlangıç tarihi olarak ayarla
    }
  }

  _fetchDavalar() {
    setState(() {
      filteredDavalar = Dava.davalar; // Başlangıçta tüm davaları göster
      Dava.davalar.sort((a, b) => b.baslamaTarihi.compareTo(a.baslamaTarihi));

      // Eğer bir tarih seçilmişse, davaları filtrele
      if (widget.selectedDate != null) {
        filteredDavalar = filteredDavalar
            .where((dava) =>
                DateFormat('dd/MM/yyyy').format(dava.baslamaTarihi) ==
                DateFormat('dd/MM/yyyy').format(widget.selectedDate!))
            .toList();
      }

      isLoading = false;
    });
  }

  void _filterDavalar(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters(); // Filtreleri uygula
    });
  }

  void _applyFilters() {
    filteredDavalar = Dava.davalar.where((dava) {
      bool matchesQuery = searchQuery.isEmpty ||
          dava.esasNo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dava.davaciAdi.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dava.davaciSoyadi.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dava.davaciTc.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dava.davaciAdresi.toLowerCase().contains(searchQuery) ||
          dava.davaciIletisim.toLowerCase().contains(searchQuery) ||
          dava.davaciMeslegi.toLowerCase().contains(searchQuery) ||
          dava.davaliAdi.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dava.davaliSoyadi.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dava.davaliTc.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dava.davaliAdresi.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dava.davaliIletisim
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.davaliMeslegi.toLowerCase().contains(searchQuery) ||
          dava.davaciVekilAdi
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.davaciVekilSoyadi
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.davaciVekilTc
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.davaciVekilAdres
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.davaliVekilAdi
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.davaliVekilSoyadi
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.davaliVekilTc
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.davaliVekilAdres
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.il.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dava.ilce.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dava.gorevliMahkeme
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.genelBilgiler
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.mahkemeAsamasi
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          dava.notlar.toLowerCase().contains(searchQuery.toLowerCase());

      bool matchesStartDate = selectedStartDate == null ||
          DateFormat('dd/MM/yyyy').format(dava.baslamaTarihi) ==
              DateFormat('dd/MM/yyyy').format(selectedStartDate!);

      return matchesQuery && matchesStartDate;
    }).toList();
  }

  Future<void> _deleteDavalar(String id) async {
    final url = Uri.parse(
        'https://bpv.tr/davalar/$id'); // Doğru URL olduğundan emin olun
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          Dava.davalar.removeWhere((dava) => dava.id.toString() == id);
          filteredDavalar = Dava.davalar;
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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = picked;
        _applyFilters(); // Tarih seçildikten sonra filtre uygula
      });
    }
  }

  void _clearStartDate() {
    setState(() {
      selectedStartDate = null; // Tarih seçimini temizle
      _applyFilters(); // Filtreleri yeniden uygula
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 52),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kaydedilenler',
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Toplam Kayıt: ${filteredDavalar.length}', // Toplam kayıt sayısını gösteriyoruz
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // Boşluk 16px olarak ayarlandı

            TextField(
              onChanged: _filterDavalar, // Arama kutusuna yazıldıkça filtrele
              decoration: InputDecoration(
                hintText: 'Ara...',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF363636),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16), // Boşluk 16px olarak ayarlandı

            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedStartDate !=
                            null // Eğer başlangıç tarihi seçilmişse, tarihi göster
                        ? ' ${DateFormat('dd/MM/yyyy').format(selectedStartDate!)}'
                        : 'Tarih Seçin',
                    style: GoogleFonts.merriweather(color: Colors.white70),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () => _selectStartDate(context),
                ),
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.white),
                  onPressed: _clearStartDate, // Tarih temizleme butonu
                ),
              ],
            ),
            SizedBox(height: 16), // Boşluk 16px olarak ayarlandı

            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: filteredDavalar.length,
                      itemBuilder: (context, index) {
                        final dava = filteredDavalar[index];
                        return GestureDetector(
                          onTap: () {
                            // Dava kartına tıklandığında EntryPage'e yönlendirme
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EntryPage(dava: dava),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 4, bottom: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFF363636),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dosya No: ${dava.esasNo}',
                                      style: GoogleFonts.merriweather(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Davacı: ${dava.davaciAdi} ${dava.davaciSoyadi}',
                                      style: GoogleFonts.merriweather(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Davalı: ${dava.davaliAdi} ${dava.davaliSoyadi}',
                                      style: GoogleFonts.merriweather(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Duruşma Tarihi: ${DateFormat('dd/MM/yyyy').format(dava.baslamaTarihi)}\n' // Duruşma tarihini formatlıyoruz
                                      'Saat: ${DateFormat('HH:mm').format(dava.baslamaTarihi)}\n' // Saat formatını ekliyoruz
                                      'İl: ${dava.il}\n',
                                      style: GoogleFonts.merriweather(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Görevli Mahkeme: ${dava.gorevliMahkeme}',
                                      style: GoogleFonts.merriweather(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert,
                                        color: Colors.white),
                                    onSelected: (value) async {
                                      if (value == 'update') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdatePage(dava: dava),
                                          ),
                                        );
                                      } else if (value == 'delete') {
                                        final shouldDelete =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Sil',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              content: Text(
                                                'Bu davayı silmek istediğinize emin misiniz?',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor: Color(
                                                  0xFF060606), // AlertDialog arka planı siyahımsı yapıyoruz
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                  child: Text('Hayır',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: Text('Evet',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (shouldDelete == true) {
                                          await _deleteDavalar(
                                              dava.id.toString());
                                        }
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        PopupMenuItem<String>(
                                          value: 'update',
                                          child: Text(
                                            'Güncelle',
                                            style: TextStyle(
                                                color: Colors
                                                    .black), // Yazı rengini beyaz yapıyoruz
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text(
                                            'Sil',
                                            style: TextStyle(
                                                color: Colors
                                                    .black), // Yazı rengini beyaz yapıyoruz
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
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
              icon: ImageIcon(AssetImage(
                  'assets/saved-activate-icon.png')), // Kaydedilenler ikonu
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
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewRegistrationPage()),
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
