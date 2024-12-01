class Dava {
  final int id;
  final String esasNo;
  final String mail;

  // Davacı Bilgileri
  final String davaciVekilAdi;
  final String davaciVekilSoyadi;
  final String davaciVekilTc;
  final String davaciVekilAdres;
  final String davaciAdi;
  final String davaciSoyadi;
  final String davaciTc;
  final String davaciAdresi;
  final String davaciIletisim;
  final String davaciMeslegi;

  // Davalı Bilgileri
  final String davaliVekilAdi;
  final String davaliVekilSoyadi;
  final String davaliVekilTc;
  final String davaliVekilAdres;
  final String davaliAdi;
  final String davaliSoyadi;
  final String davaliTc;
  final String davaliAdresi;
  final String davaliIletisim;
  final String davaliMeslegi;

  // Genel Bilgiler
  final String genelBilgiler;
  final String mahkemeAsamasi;
  final String il;
  final String ilce;
  final DateTime baslamaTarihi;
  final DateTime durusmaTarihi;
  final String gorevliMahkeme;
  final String count;
  final String notlar;

  static late List<Dava> davalar;
  static List<DateTime> selectedDates = [];
  Dava({
    required this.id,
    required this.esasNo,
    required this.mail,
    required this.davaciVekilAdi,
    required this.davaciVekilSoyadi,
    required this.davaciVekilTc,
    required this.davaciVekilAdres,
    required this.davaciAdi,
    required this.davaciSoyadi,
    required this.davaciTc,
    required this.davaciAdresi,
    required this.davaciIletisim,
    required this.davaciMeslegi,
    required this.davaliVekilAdi,
    required this.davaliVekilSoyadi,
    required this.davaliVekilTc,
    required this.davaliVekilAdres,
    required this.davaliAdi,
    required this.davaliSoyadi,
    required this.davaliTc,
    required this.davaliAdresi,
    required this.davaliIletisim,
    required this.davaliMeslegi,
    required this.genelBilgiler,
    required this.il,
    required this.ilce,
    required this.baslamaTarihi,
    required this.durusmaTarihi,
    required this.gorevliMahkeme,
    required this.mahkemeAsamasi,
    required this.count,
    required this.notlar,
  });

  factory Dava.fromJson(Map<String, dynamic> json) {
    return Dava(
      id: json['id'],
      esasNo: json['esasNo'],
      mail: json['mail'],
      davaciVekilAdi: json['davaciVekilAdi'],
      davaciVekilSoyadi: json['davaciVekilSoyadi'],
      davaciVekilTc: json['davaciVekilTc'],
      davaciVekilAdres: json['davaciVekilAdres'],
      davaciAdi: json['davaciAdi'],
      davaciSoyadi: json['davaciSoyadi'],
      davaciTc: json['davaciTc'],
      davaciAdresi: json['davaciAdresi'],
      davaciIletisim: json['davaciIletisim'],
      davaciMeslegi: json['davaciMeslegi'],
      davaliVekilAdi: json['davaliVekilAdi'],
      davaliVekilSoyadi: json['davaliVekilSoyadi'],
      davaliVekilTc: json['davaliVekilTc'],
      davaliVekilAdres: json['davaliVekilAdres'],
      davaliAdi: json['davaliAdi'],
      davaliSoyadi: json['davaliSoyadi'],
      davaliTc: json['davaliTc'],
      davaliAdresi: json['davaliAdresi'],
      davaliIletisim: json['davaliIletisim'],
      davaliMeslegi: json['davaliMeslegi'],
      genelBilgiler: json['genelBilgiler'],
      il: json['il'],
      ilce: json['ilce'],
      baslamaTarihi: DateTime.parse(json['baslamaTarihi']),
      durusmaTarihi: DateTime.parse(json['durusmaTarihi']),
      gorevliMahkeme: json['gorevliMahkeme'],
      mahkemeAsamasi: json['mahkemeAsamasi'],
      count: json['count'],
      notlar: json['notlar'],
    );
  }

  static List<Dava> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Dava.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
