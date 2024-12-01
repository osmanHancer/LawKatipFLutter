import 'dart:convert'; // JSON işlemleri için
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katip/calendar.dart';
import 'package:katip/entity/davalar.dart';
import 'package:katip/entity/person.dart';
import 'package:katip/new.dart';
import 'package:katip/profile.dart';
import 'package:http/http.dart' as http; // HTTP paketini import ediyoruz.
import 'saved.dart';
import 'package:katip/entry.dart'; // EntryPage import

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Dava> davalar = []; // Dinamik dava listesi
  bool isLoading = true; // Verilerin yüklendiğini gösteren durum
  int _todayCourtCount = 0; // Bugün olan duruşmaların sayısı

  @override
  void initState() {
    super.initState();
    _fetchDavalar(); // Verileri çekmek için fonksiyonu çağırıyoruz.
  }

  Future<void> _fetchDavalar() async {
    setState(() {
      davalar = Dava.davalar;

      DateTime today = DateTime.now();

      // Bugün olan duruşmaların sayısını hesapla
      _todayCourtCount = davalar
          .where((dava) => _isSameDay(dava.baslamaTarihi, today))
          .length;

      davalar.sort((a, b) => a.baslamaTarihi.compareTo(b.baslamaTarihi));
      isLoading = false;
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _greetingMessage() {
    final currentHour = DateTime.now().hour;
    if (currentHour >= 6 && currentHour < 12) {
      return 'Günaydın';
    } else if (currentHour >= 12 && currentHour < 19) {
      return 'Merhaba';
    } else if (currentHour >= 19 && currentHour < 24) {
      return 'İyi Akşamlar';
    } else if (currentHour >= 0 && currentHour < 6) {
      return 'İyi Geceler';
    }
    return 'Merhaba';
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('tr', null);
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF060606),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 52),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF292929),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greetingMessage()} ${Person.person.name[0].toUpperCase()}${Person.person.name.substring(1).toLowerCase()}',
                          style: GoogleFonts.merriweather(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Bugün ',
                              style: GoogleFonts.merriweather(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF8E1717),
                              ),
                              child: Center(
                                child: Text(
                                  _todayCourtCount.toString(),
                                  style: GoogleFonts.merriweather(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              ' Duruşman Var',
                              style: GoogleFonts.merriweather(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: Person.person.imgname != null
                                ? NetworkImage(
                                'https://bpv.tr/file/${Person.person.imgname}')
                                : const AssetImage('assets/default-profile.png') as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Gelecek Duruşmalar',
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : davalar.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 55),
                  child: Text(
                    'Henüz kayıt oluşturulmadı',
                    style: GoogleFonts.merriweather(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
                  : SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: davalar.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: CourtCard(dava: davalar[index]),
                    );
                  },
                ),
              ),
              SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Takvim',
                    style: GoogleFonts.merriweather(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SavedPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Tümünü Gör',
                          style: GoogleFonts.merriweather(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image.asset('assets/arrow-right-icon.png',
                          width: 12, height: 12),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Expanded(
                child: CalendarWidget(davalar: davalar),
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
            backgroundColor: const Color(0xFF252525),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedPage()),
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
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
            ),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/home-activate-icon.png'),
                  color: Colors.white,
                ),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/saved-line-icon.png'),
                  color: Colors.white,
                ),
                label: 'Kaydedilenler',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/new-line-icon.png'),
                  color: Colors.white,
                ),
                label: 'Yeni',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/calendar-line-icon.png'),
                  color: Colors.white,
                ),
                label: 'Takvim',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage('assets/profile-line-icon.png'),
                  color: Colors.white,
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourtCard extends StatelessWidget {
  final Dava dava;

  CourtCard({required this.dava});

  @override
  Widget build(BuildContext context) {
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
        width: 213,
        height: 131,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esas No: ${dava.esasNo}',
              style: GoogleFonts.merriweather(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.black45,
              ),
              overflow: TextOverflow.ellipsis, // Metin taşarsa "..." ile kısaltılır
            ),
            SizedBox(height: 4),
            Text(
              'Davacı: ${dava.davaciAdi} ${dava.davaciSoyadi}',
              style: GoogleFonts.merriweather(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis, // Metin taşarsa "..." ile kısaltılır
            ),
            Text(
              'Davalı: ${dava.davaliAdi} ${dava.davaliSoyadi}',
              style: GoogleFonts.merriweather(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis, // Metin taşarsa "..." ile kısaltılır
            ),
            Divider(
              color: Colors.black45,
              thickness: 1,
              height: 12,
            ),
            Row(
              children: [
                Image.asset('assets/location-icon.png', width: 16, height: 16),
                SizedBox(width: 4),
                Text('${dava.il}',
                  style: GoogleFonts.merriweather(
                      fontSize: 10, color: Colors.black87),
                  overflow: TextOverflow.ellipsis, // Metin taşarsa "..." ile kısaltılır
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset('assets/calendar-icon.png',
                        width: 16, height: 16),
                    SizedBox(width: 4),
                    Text(DateFormat('dd.MM.yyyy').format(dava.baslamaTarihi),
                        style: GoogleFonts.merriweather(
                            fontSize: 10, color: Colors.black87)),
                  ],
                ),
                Row(
                  children: [
                    Image.asset('assets/clock-icon.png', width: 16, height: 16),
                    SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(dava.baslamaTarihi),
                      style: GoogleFonts.merriweather(
                          fontSize: 10, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// Takvim Widget'ı
class CalendarWidget extends StatefulWidget {
  final List<Dava> davalar; // Dava listesini alıyoruz

  CalendarWidget({required this.davalar}); // Yapıcı fonksiyon

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _selectedDate = DateTime.now();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedDate.month - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: _prevMonth,
            ),
            GestureDetector(
              onTap: () => _selectMonthYear(context), // Ay ve yıl seçici dialog
              child: Text(
                DateFormat.yMMMM('tr').format(_selectedDate),
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: _nextMonth,
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var day in ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'])
              Text(
                day,
                style: GoogleFonts.merriweather(fontSize: 12, color: Colors.white),
              ),
          ],
        ),
        SizedBox(height: 8),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              DateTime displayMonth = DateTime(_selectedDate.year, index + 1);
              return _buildCalendar(displayMonth);
            },
            onPageChanged: (index) {
              setState(() {
                _selectedDate = DateTime(_selectedDate.year, index + 1);
              });
            },
            clipBehavior: Clip.none,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(DateTime displayMonth) {
    int daysInMonth =
    DateUtils.getDaysInMonth(displayMonth.year, displayMonth.month);
    List<Widget> dayWidgets = [];

    int firstDayOfWeek =
        DateTime(displayMonth.year, displayMonth.month, 1).weekday % 7;
    for (int i = 0; i < firstDayOfWeek; i++) {
      dayWidgets.add(Container());
    }

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(displayMonth.year, displayMonth.month, i);
      dayWidgets.add(_buildDay(date));
    }

    return GridView.count(
      crossAxisCount: 7,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      clipBehavior: Clip.none,
      children: dayWidgets,
    );
  }

  Widget _buildDay(DateTime date) {
    int courtCount = widget.davalar
        .where((dava) =>
    dava.baslamaTarihi.year == date.year &&
        dava.baslamaTarihi.month == date.month &&
        dava.baslamaTarihi.day == date.day)
        .length;

    bool hasCourt = courtCount > 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SavedPage(selectedDate: date),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: hasCourt ? const Color(0xFF8E1717) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                '${date.day}',
                style: GoogleFonts.merriweather(fontSize: 12, color: Colors.white),
              ),
            ),
            if (courtCount > 0)
              Positioned(
                top: -8,
                left: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF363636),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$courtCount',
                    style: const TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _nextMonth() {
    setState(() {
      if (_selectedDate.month == 12) {
        _selectedDate = DateTime(_selectedDate.year + 1, 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      }
      _pageController.jumpToPage(_selectedDate.month - 1);
    });
  }

  void _prevMonth() {
    setState(() {
      if (_selectedDate.month == 1) {
        _selectedDate = DateTime(_selectedDate.year - 1, 12);
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      }
      _pageController.jumpToPage(_selectedDate.month - 1);
    });
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    int selectedYear = _selectedDate.year;
    int selectedMonth = _selectedDate.month;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Color(0xFF060606), // Arka plan rengi 060606
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Yıl Seçimi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white), // Beyaz ok ikonu
                          onPressed: () {
                            setState(() {
                              selectedYear--;
                            });
                          },
                        ),
                        Text(
                          selectedYear.toString(),
                          style: GoogleFonts.merriweather(fontSize: 20, color: Colors.white), // Beyaz yazı
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios, color: Colors.white), // Beyaz ok ikonu
                          onPressed: () {
                            setState(() {
                              selectedYear++;
                            });
                          },
                        ),
                      ],
                    ),
                    Divider(color: Colors.white), // Beyaz çizgi
                    // Ay Seçimi
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      children: List.generate(12, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMonth = index + 1;
                            });
                            Navigator.of(context).pop(); // Seçimi tamamla
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedMonth == index + 1
                                  ? Color(0xFF8E1717) // Seçilen ayın rengi 0xFF8E1717
                                  : Colors.transparent, // Diğer aylar şeffaf
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                DateFormat.MMMM('tr').format(DateTime(0, index + 1)),
                                style: GoogleFonts.merriweather(fontSize: 16, color: Colors.white), // Beyaz yazı
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    setState(() {
      _selectedDate = DateTime(selectedYear, selectedMonth, _selectedDate.day);
      _pageController.jumpToPage(selectedMonth - 1); // Seçilen aya git
    });
  }
}
