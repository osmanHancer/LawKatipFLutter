class Person {
  final String name;
  final String surname;
  final String mail;
  final String? imgname; // imgname null olabilir

  static late Person person;
  static late String passw;
  static late String email;

  Person({
    required this.name,
    required this.surname,
    required this.mail,
    this.imgname, // imgname opsiyonel olarak tanımlandı
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      surname: json['surname'],
      mail: json['mail'],
      imgname: json['imgname'] != null ? json['imgname'] : null, // imgname null olabilir
    );
  }
}
