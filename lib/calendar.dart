import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatı için gerekli paket
import 'package:intl/date_symbol_data_local.dart'; // Türkçe tarih desteği için gerekli paket
import 'package:google_fonts/google_fonts.dart'; // Google Fonts paketi
import 'package:katip/entity/davalar.dart';
import 'profile.dart'; // ProfilePage'i içe aktar
import 'saved.dart'; // Kaydedilenler sayfası
import 'home.dart'; // Ana sayfa
import 'new.dart'; // Yeni sayfa

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now(); // Varsayılan seçili gün bugünün tarihi
  ScrollController _scrollController = ScrollController(); // Yatay kaydırma için kontrolcü
  int _selectedIndex = 3; // Takvim sayfası aktif olduğu için varsayılan index
  List<Map<String, String>?> upcomingWeekPlans = [];
  int initialDayIndex = 182; // Bugünden itibaren 6 ay öncesi ve sonrası için başlangıç index'i

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr', null); // Türkçe tarih formatı
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int todayIndex = DateTime.now().difference(DateTime.now()).inDays + initialDayIndex; // Bugünün indeksini hesapla
      _centerSelectedDay(todayIndex); // Sayfa yüklendiğinde bugünü ortala
    });
    _loadUpcomingPlans(); // Hatırlatıcılar için planları yükle
  }


  void _centerToday() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double screenWidth = MediaQuery.of(context).size.width;
      double selectedDayOffset = (initialDayIndex * 76) - (screenWidth / 2) + 54; // Günün ortalanması için offset
      _scrollController.animateTo(
        selectedDayOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }


  void _loadUpcomingPlans() {
    DateTime now = DateTime.now();
    DateTime oneWeekLater = now.add(const Duration(days: 7)); // 1 hafta sonrası

    upcomingWeekPlans = Dava.davalar.map((dava) {
      DateTime startTime = dava.baslamaTarihi;
      DateTime endTime = startTime.add(const Duration(hours: 1)); // 1 saat ekliyoruz

      bool isWithinNextWeek = startTime.isAfter(now) && startTime.isBefore(oneWeekLater);

      String formattedTime =
          '${DateFormat.Hm().format(startTime)} - ${DateFormat.Hm().format(endTime)}';

      if (isWithinNextWeek) {
        return {
          'day': "${startTime.day}-${startTime.month}-${startTime.year}",
          'title': dava.davaciAdi,
          'subtitle': dava.davaliAdi,
          'time': formattedTime,
          'description': dava.gorevliMahkeme,
        };
      } else {
        return null;
      }
    }).where((plan) => plan != null).toList();
  }

  Widget _buildDayItem(DateTime date) {
    bool isSelected = date.day == selectedDate.day &&
        date.month == selectedDate.month &&
        date.year == selectedDate.year;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
          int selectedIndex = date.difference(DateTime.now()).inDays + initialDayIndex; // Seçilen günün dizinini hesapla
          _centerSelectedDay(selectedIndex); // Seçilen günü ortala
        });
      },


      child: Container(
        width: 60, // Gün hücresinin genişliği
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF780101)
              : Colors.transparent, // Seçili gün rengi
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat.E('tr').format(date), // Günün adı (Pzt, Sal, Çar...)
              style: GoogleFonts.merriweather(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(), // Günün tarihi
              style: GoogleFonts.merriweather(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ay seçici diyaloğunu gösteren fonksiyon
  Future<void> _selectMonth(BuildContext context) async {
    int? selectedMonth = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempMonth = selectedDate.month;
        int tempYear = selectedDate.year;
        return AlertDialog(
          backgroundColor: Color(0xFF060606),
          title: Text(
            'Ay Seçin',
            style: TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: 150,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: DropdownButton<int>(
                        dropdownColor: Colors.grey[800],
                        value: tempMonth,
                        items: List.generate(12, (index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text(
                              DateFormat.MMMM('tr').format(DateTime(0, index + 1)),
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }),
                        onChanged: (int? newValue) {
                          setState(() {
                            tempMonth = newValue!;
                          });
                        },
                        isExpanded: true,
                        underline: Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: DropdownButton<int>(
                        dropdownColor: Colors.grey[800],
                        value: tempYear,
                        items: List.generate(5, (index) {
                          int year = DateTime.now().year - 2 + index;
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(
                              year.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }),
                        onChanged: (int? newValue) {
                          setState(() {
                            tempYear = newValue!;
                          });
                        },
                        isExpanded: true,
                        underline: Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('İptal', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Tamam', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(tempMonth);
                setState(() {
                  selectedDate = DateTime(tempYear, tempMonth, selectedDate.day);
                });
                _scrollToSelectedMonth();
              },
            ),
          ],
        );
      },
    );
  }

  void _scrollToSelectedMonth() {
    DateTime now = DateTime.now();
    int daysDifference = selectedDate.difference(now).inDays;
    double screenWidth = MediaQuery.of(context).size.width;
    double offset = (daysDifference + initialDayIndex) * 76 - (screenWidth / 2);
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _centerSelectedDay(int index) {
    double screenWidth = MediaQuery.of(context).size.width;
    double selectedDayOffset = (index * 76) - (screenWidth / 2) + 52; // 55px sağa kaydırmak için eklendi
    _scrollController.animateTo(
      selectedDayOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }



  Widget _buildMonthIndicator() {
    return GestureDetector(
      onTap: () {
        _selectMonth(context);
      },
      child: Center(
        child: Text(
          DateFormat.yMMMM('tr').format(selectedDate), // Ay adı ve yıl
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyPlans() {
    List<Map<String, String>?> plans = Dava.davalar.map((dava) {
      DateTime startTime = dava.baslamaTarihi;
      DateTime endTime = startTime.add(const Duration(hours: 1)); // 1 saat ekliyoruz
      DateTime selectedDateStart =
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      DateTime selectedDateEnd = selectedDateStart.add(const Duration(days: 1));

      bool isWithinSelectedDate = startTime.isBefore(selectedDateEnd) &&
          endTime.isAfter(selectedDateStart);
      String formattedTime =
          '${DateFormat.Hm().format(startTime)} - ${DateFormat.Hm().format(endTime)}';

      if (isWithinSelectedDate) {
        return {
          'title': dava.davaciAdi,
          'subtitle': dava.davaliAdi,
          'time': formattedTime,
          'description': dava.gorevliMahkeme,
        };
      } else {
        return null;
      }
    }).where((plan) => plan != null).toList();

    return SizedBox(
      width: 390, // Genişlik
      height: 340, // Yükseklik
      child: ListView.builder(
        itemCount: 24, // 24 saat
        itemBuilder: (context, index) {
          String time = '${index.toString().padLeft(2, '0')}:00'; // 24 saat formatı
          Map<String, String>? plan = plans.firstWhere(
                (p) {
              List<String>? times = p?['time']!.split(' - ');
              String start = times![0];
              String end = times[1];
              return time.compareTo(start) >= 0 && time.compareTo(end) < 0;
            },
            orElse: () => {},
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (plan!.isNotEmpty)
                      Expanded(
                        child: _buildPlanCard(plan['title']!, plan['subtitle']!,
                            plan['time']!, plan['description']!),
                      ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey), // Saat arası çizgi
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(
      String title, String subtitle, String time, String description) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF363636),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                time,
                style: GoogleFonts.merriweather(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.merriweather(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.merriweather(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.merriweather(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDateScroller() {
    return SizedBox(
      height: 80, // Yatay kaydırma alanının yüksekliği
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 365, // 365 gün
        itemBuilder: (context, index) {
          DateTime currentDate = DateTime.now().add(Duration(days: index - initialDayIndex));
          return _buildDayItem(currentDate);
        },
      ),
    );
  }

  Widget _buildReminderCard(String title, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF363636),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.event, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: GoogleFonts.merriweather(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 52), // Üst boşluk
              Center(
                child: Text(
                  'Takvim',
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildMonthIndicator(),
              const SizedBox(height: 20),
              _buildDateScroller(),
              const SizedBox(height: 20),
              Text(
                'Bugün Planlananlar',
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildHourlyPlans(),
              const SizedBox(height: 20),
              Text(
                'Hatırlatıcı',
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Yapılacaklar',
                style: GoogleFonts.merriweather(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              ...upcomingWeekPlans.map((plan) {
                return _buildReminderCard(
                  '${plan!['title']} - ${plan['subtitle']}',
                  plan['day']!,
                );
              }).toList(),
            ],
          ),
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
          backgroundColor: const Color(0xFF252525), // Arka plan rengi
          selectedItemColor: Colors.white, // Seçilen öğenin simge rengi
          unselectedItemColor: Colors.white, // Seçilmeyen öğelerin simge rengi
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          enableFeedback: false,
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
              icon: ImageIcon(AssetImage('assets/calendar-activate-icon.png')),
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
                MaterialPageRoute(
                  builder: (context) => HomePage(), // Ana Sayfa'ya yönlendirme
                ),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedPage(), // Kaydedilenler sayfası
                ),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewRegistrationPage(), // Yeni sayfası
                ),
              );
            } else if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(), // Profil sayfası
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
