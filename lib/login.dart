import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:katip/entity/person.dart';
import 'package:katip/forgot_password.dart';
import 'package:katip/splash_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  static const int animationDuration = 1200; // Giriş ve kaydol için aynı süre
  @override
  void initState() {
    super.initState();
    loadLoginData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: animationDuration),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 10).animate(_controller);
  }

  bool _showSignIn = false;
  bool _showSignUp = false;
  bool _kvkkApproved = false;
  bool _infoApproved = false;
  bool _receiveEmails = false;
  final _formKey = GlobalKey<FormState>();

  String? _nameError;
  String? _surnameError;
  String? _emailError;
  String? _passwordError;

  bool _passwordVisible = false; // Şifre alanı için
  bool _confirmPasswordVisible = false; // Şifre tekrar alanı için
  bool _userpasswordVisible = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen e-posta adresinizi girin';
    }

    // E-posta adresinin başındaki ve sonundaki boşlukları kaldır
    final trimmedValue = value.trim();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Geçerli bir e-posta adresi girin';
    }

    return null;
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _validatepasswordController =
      TextEditingController();
  final TextEditingController _validateemailController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  Future<http.Response> createPerson() {
    return http.post(
      Uri.parse('https://bpv.tr/users/insert'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': _nameController.text,
        'surname': _surnameController.text,
        'mail': _emailController.text,
        'hashedPassword': _passwordController.text,
      }),
    );
  }

  Future<void> performLogin() async {
    if (_formKey.currentState!.validate()) {
      _validateemailController.text = _validateemailController.text.trim();
      _validatepasswordController.text =
          _validatepasswordController.text.trim();

      http.Response message =
          await validatePerson(); // Giriş işlemini gerçekleştirin

      Map<String, dynamic> jsonResponse = jsonDecode(message.body);
      log(jsonResponse["message"].toString());

      if (jsonResponse["message"] == "Login successful") {
        // Kullanıcı bilgilerini sakla
        await secureStorage.write(
            key: 'email', value: _validateemailController.text);
        await secureStorage.write(
            key: 'password', value: _validatepasswordController.text);

        Person.person = Person.fromJson(jsonResponse["user"]);
        Person.passw = _validatepasswordController.text;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      } else {
        // Hata mesajları
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse["message"]),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void loadLoginData() async {
    String? email = await secureStorage.read(key: 'email');
    String? password = await secureStorage.read(key: 'password');

    if (email != null) {
      _validateemailController.text = email;
    }
    if (password != null) {
      _validatepasswordController.text = password;
    }

    // Giriş kontrolünü burada yapabilirsiniz
    if (email != null && password != null) {
      await performLogin();
    }
  }

  Future<http.Response> validatePerson() {
    return http.post(
      Uri.parse('https://bpv.tr/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'mail': _validateemailController.text,
        'hashedPassword': _validatepasswordController.text
      }),
    );
  }

  String? validateName(String name) {
    if (name.isEmpty) {
      return "İsim alanı boş bırakılamaz";
    }
    return null;
  }

  String? validateSurname(String surname) {
    if (surname.isEmpty) {
      return "Soyisim alanı boş bırakılamaz";
    }
    return null;
  }

  String? validateEmail(String email) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (email.isEmpty) {
      return "E-posta alanı boş bırakılamaz";
    } else if (!regex.hasMatch(email)) {
      return "Geçerli bir e-posta adresi giriniz";
    }
    return null;
  }

  String? validatePasswords(String password, String confirmPassword) {
    final RegExp hasUppercase = RegExp(r'[A-Z]');
    final RegExp hasLowercase = RegExp(r'[a-z]');
    final RegExp hasDigit = RegExp(r'[0-9]');
    final RegExp hasSpecialCharacter = RegExp(r'[!@#\$&*~]');

    if (password.isEmpty || confirmPassword.isEmpty) {
      return "Şifre alanları boş bırakılamaz";
    } else if (password.length < 8) {
      return "Şifre en az 8 karakter olmalı";
    } else if (!hasUppercase.hasMatch(password)) {
      return "Şifre en az bir büyük harf içermelidir";
    } else if (!hasLowercase.hasMatch(password)) {
      return "Şifre en az bir küçük harf içermelidir";
    } else if (!hasDigit.hasMatch(password)) {
      return "Şifre en az bir rakam içermelidir";
    } else if (!hasSpecialCharacter.hasMatch(password)) {
      return "Şifre en az bir özel karakter içermelidir";
    } else if (password != confirmPassword) {
      return "Şifreler eşleşmiyor";
    }
    return null;
  }

  void _showKVKKPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF060606), // Arka plan rengini ayarlıyoruz
          title: const Text(
            'KVKK Metni',
            style: TextStyle(
                color: Colors.white), // Başlık metnini beyaz yapıyoruz
          ),
          content: const SizedBox(
            height: 550,
            child: SingleChildScrollView(
              child: Text(
                "6698 SAYILI KİŞİSEL VERİLERİN KORUNMASI KANUNU KAPSAMINDA AHKAM DEFTERİ UYGULAMASI İÇİN AYDINLATMA METNİ\n\n"
                "Aydınlatma Metni Amacı\n\n"
                "AHKAM DEFTERİ  olarak 6698 sayılı Kişisel Verilerin Korunması Kanunu (‘KVKK’ veya ‘Kanun’ olarak "
                "anılacaktır.) kapsamında kişisel verilerinizin korunması için tedbir almaktayız. Kişisel verilerinizi, "
                "KVKK ve ilgili yasal mevzuat kapsamında ve ‘veri sorumlusu’ sıfatımızla aşağıda açıklanan sebeplerle "
                "ve yöntemlerle işlemekteyiz. Kişisel Verilerin İşlenmesi Hakkında Aydınlatma Metni, KVKK'nın 10. "
                "maddesinde yer alan ‘Veri Sorumlusunun Aydınlatma Yükümlülüğü’ başlıklı maddesi uyarınca; veri "
                "sorumlusunun kimliği, kişisel verilerinizin toplanma yöntemi ve hukuki sebebi, bu verilerin hangi "
                "amaçla işleneceği, kimlere ve hangi amaçla aktarılabileceği, veri işleme süresi ve KVKK'nın 11. "
                "Maddesinde sayılan haklarınızın neler olduğu ile ilgili sizi en şeffaf şekilde bilgilendirme "
                "amacıyla hazırlanmıştır.\n\n"
                "1- Veri Sorumlusu ve Temsilcisi\n"
                "KVKK (‘6698 sayılı Kanun’) uyarınca, kişisel verileriniz; veri sorumlusu olarak AHKAM DEFTERİ "
                "tarafından aşağıda açıklanan kapsamda işlenebilecektir.\n\n"
                "Veri sorumlusu :  YILMAZ UZUN\n"
                "Kayıtlı olduğu oda: Elazığ Esnaf ve Sanatkarlar Odası\n"
                "Sicil Numarası: 53967\n"
                "Adres : Cumhuriyet Mah. 151 Sok. Kapı no 9/1 Merkez Elazığ\n"
                "Telefon: +90 541 893 07 51\n"
                "E-posta: ylmzuzun1@gmail.com\n\n"
                "2- İşlenen Kişisel Verileriniz ve İşlenme Amaçları"
                "Toplanan kişisel verileriniz; AHKAM DEFTERİ uygulaması için gerekli amacın yerine getirilmesi, "
                "avukatların vekaletlerini sunduğu dosyaların ;dosya no/ esas no bilgileri ,taraf bilgileri , "
                "görevli ve yetkili mahkeme bilgileri, mahkemenin hangi aşamada olduğunu göstermek amaçlarıyla "
                "6698 sayılı Kanun'un 5. ve 6. maddelerinde belirtilen kişisel veri işleme şartları ve amaçları "
                "dahilinde işlenecektir. Bu kapsamda kişisel veri olarak aşağıda yer alan veriler toplanmaktadır.\n"
                "Kimlik: Ad-Soyad, TC Kimlik Numarası\n"
                "İletişim: Adres, Cep Telefon Numarası, E-posta\n\n"
                "3- İşlenen Kişisel Verilerinizin Kimlere ve Hangi Amaçla Aktarılabileceği\n"
                "KVKK uyarınca uygun güvenlik düzeyini temin etmeye yönelik gerekli her türlü teknik ve idari "
                "tedbirlerin alınmasını sağlayarak, Kişisel Veri/Kişisel Verilerinizi yukarıda belirtilen amaçlar "
                "doğrultusunda; faaliyetlerinin yürütülmesi ve hizmet kalitesinin artırılması amacıyla veya yasal "
                "bir zorunluluk gereği bu verileri talep etmeye yetkili olan kamu kurum veya kuruluşlarla "
                "paylaşabilecektir. 6698 sayılı Kanun'un 8. ve 9. maddelerinde belirtilen kişisel veri işleme "
                "şartları ve amaçları çerçevesinde aktarılabilecektir.\n\n"
                "4- Kişisel Verilerinizin Toplanma Yöntemi ve Hukuki Sebebi\n"
                "Kişisel verileriniz, kanunun 5. maddesinde belirtilen ‘sözleşmenin ifası’ hukuki sebeplerine dayalı "
                "olarak ilgili kişiden fiziki ve dijital olarak toplanmaktadır.\n\n"
                "5- Kişisel Veri Sahibinin 6698 sayılı Kanun'un 11. maddesinde Sayılan Hakları ve Bu Haklarını Kullanması\n"
                "Kişisel verisi işlenen ilgili kişilerin hakları Kişisel verisi işlenen ilgili kişileri aşağıda yer "
                "alan haklara sahiptirler:\n"
                "a. Kişisel veri işlenip işlenmediğini öğrenme,\n"
                "b. Kişisel verileri işlenmişse buna ilişkin bilgi talep etme,\n"
                "c. Kişisel verilerin işlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme,\n"
                "ç. Yurt içinde veya yurt dışında kişisel verilerin aktarıldığı üçüncü kişileri bilme,\n"
                "d. Kişisel verilerin eksik veya yanlış işlenmiş olması hâlinde bunların düzeltilmesini "
                "isteme ve bu kapsamda yapılan işlemin kişisel verilerin aktarıldığı üçüncü kişilere "
                "bildirilmesini isteme,\n"
                "e. KVK Kanunu ve ilgili diğer kanun hükümlerine uygun olarak işlenmiş olmasına rağmen, "
                "işlenmesini gerektiren sebeplerin ortadan kalkması hâlinde kişisel verilerin silinmesini "
                "veya yok edilmesini isteme ve bu kapsamda yapılan işlemin kişisel verilerin aktarıldığı "
                "üçüncü kişilere bildirilmesini isteme,\n"
                "f. (d) ve (e) bentleri uyarınca yapılan işlemlerin, kişisel verilerin aktarıldığı üçüncü "
                "kişilere bildirilmesini isteme,\n"
                "g. İşlenen verilerin münhasıran otomatik sistemler vasıtasıyla analiz edilmesi suretiyle "
                "kişinin kendisi aleyhine bir sonucun ortaya çıkması halinde bu sonuca itiraz etme,\n"
                "ğ. Kişisel verilerin kanuna aykırı olarak işlenmesi sebebiyle zarara uğraması halinde zararın"
                "giderilmesini talep etme.\n\n"
                "6- İlgili kişinin Haklarını Kullanması\n"
                "Kişisel veri sahipleri olarak, haklarınıza ilişkin taleplerinizi şirketimize iletmeniz "
                "durumunda şirketimiz talebin niteliğine göre talebi en kısa sürede ve en geç otuz gün "
                "içinde sonuçlandıracaktır. Ancak, işlemin ayrıca bir maliyeti gerektirmesi hâlinde, "
                "şirket tarafından Kişisel Verileri Koruma Kurulunca belirlenen tarifedeki ücret "
                "alınacaktır. Kanunun ‘ilgili kişinin haklarını düzenleyen’ 11. maddesi kapsamındaki "
                "taleplerinizi, ‘Veri Sorumlusuna Başvuru Usul ve Esasları Hakkında Tebliğe’ göre "
                "Cumhuriyet Mah. 151 Sok. Kapı no 9/1 Merkez Elazığ  adresine yazılı olarak iletebilirsiniz.\n"
                "Bu konuda kapsamlı düzenleme Kişisel Verilerin Korunması ve İşlenmesi Politikasında yapılmıştır.\n",
                style: TextStyle(color: Colors.white60),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Kapat',
                style: TextStyle(
                    color: Colors.white), // Buton metnini beyaz yapıyoruz
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF060606), // Arka plan rengini ayarlıyoruz
          title: const Text(
            'Kullanıcı Sözleşmesi Metni',
            style: TextStyle(
                color: Colors.white), // Başlık metnini beyaz yapıyoruz
          ),
          content: const SizedBox(
            height: 550,
            child: SingleChildScrollView(
              child: Text(
                "AHKAM DEFTERİ MOBİL UYGULAMASI KULLANICI SÖZLEŞMESİ\n\n"
                "Madde 1\n"
                "Taraflar\n"
                "İşbu Kullanıcı Sözleşmesi (‘Sözleşme’), Yılmaz Uzun  (‘Şirket’) ile Şirket tarafından işletilmekte olan "
                "ahkamdefteri.com (‘Site’) İnternet Siteleri domain ve subdominleri üzerinden Site’de yer alan ürünleri "
                "kullanmak adına ‘Kullanıcı’ sıfatıyla kaydolan kişi arasında akdedilmektedir. Sözleşme, Kullanıcı "
                "tarafından sözleşmenin elektronik ortamda kabulü ile birlikte yürürlüğe girecek olup; sözleşmeye uygun "
                "olarak taraflarca sona erdirilmediği veya haklı nedenle sözleşmenin feshedilebileceği bir durum "
                "oluşmadığı sürece yürürlükte kalmaya devam edecektir.\n\n"
                "Madde 2\n"
                "Sözleşme’nin Konusu ve Kapsamı\n"
                "2.1.Site kapsamında Site ve hizmetlerin kullanımına ilişkin olarak Sitede yayınlanarak kullanıcılara "
                "ilan edilen tüm kural ve şartlar da işbu Sözleşme’nin eki ve ayrılmaz bir parçası niteliğinde olup "
                "burada yer alan hak ve yükümlülüklerle birlikte tarafların tüm hak ve yükümlülüklerini oluşturur.\n\n"
                "2.2.İşbu Sözleşme, Şirket tarafından tüm fikri mülkiyet hakları kendisine ait olarak oluşturulan ve "
                "kullanıcının kullanıcı hesabı oluşturmak kaydıyla faydalanabileceği kullanıcı olan avukatların "
                "vekaletlerini sunduğu dosyaların ;dosya no/ esas no bilgileri ,taraf bilgileri , görevli ve yetkili "
                "mahkeme bilgileri, mahkemenin hangi aşamada olduğunu göstermek için tutulan takvim, ajanda vb. "
                "hizmetlerini kullanıcılara sunan ve ücretsiz olarak sunduğu diğer hizmetlerden yararlanılmasına "
                "ilişkin koşul ve şartlar ile ilgili tarafların hak ve yükümlülüklerinin belirlenmesi amacıyla "
                "akdedilmektedir.\n\n"
                "Madde 3\n"
                "Tarafların Hak ve Yükümlülükleri\n"
                "3.1. Ahkam Defteri uygulaması hizmetlerinden faydalanmak adına Kullanıcı sıfatını kazanabilmek için "
                "Şirket tarafından talep edilen bilgilerin eksiksiz, güncel ve gerçeğe uygun olarak Kullanıcı tarafından "
                "sağlanması ve işbu Sözleşmenin yine Kullanıcı tarafından onaylanması gerekir. Kullanıcı, sözleşmeyi "
                "onaylarken verdiği bilgilerde bir değişiklik olması durumunda güncel bilgileri azami 15 gün içinde "
                "Şirket’e bildirmek zorundadır. Verilen bilgilerin eksik olması veya doğru olmaması yahut güncelliğini "
                "kaybetmiş olması nedeniyle Site ya da hizmetlere erişim sağlanamaması ve/veya Site ya da hizmetlerden "
                "faydalanılamaması durumunda Şirketin herhangi bir sorumluluğu doğmaz.\n\n"
                "3.2. Kullanıcı, işbu Sözleşmeyi akdetmeye engel yasal bir engelinin bulunmadığını(gerçek kişiler yasal "
                "ehliyeti haiz olduğunu ve tüzel kişi temsilcisi de yetkili temsilci bulunduğunu) kabul ve beyan eder.\n\n"
                "3.3. Şirket tarafından her bir hizmet/ Kullanıcıya tek bir hizmet/Kullanıcı hesabı açılır.\n\n"
                "3.4. Ürünlere erişim, kullanıcı adı ve şifrenin site üzerinde girilmesiyle mümkün olur. Başka bir "
                "kullanıcı adı belirlenmediği takdirde, kullanıcı adı, tanımlanan e-posta adresine bağlı oluşturulan "
                "kullanıcı adıdır. Kullanıcı adı ve şifresi, kullanıcı hesabının tanımlı olduğu kişi veya bir tüzel "
                "kişilik ise ürünü kullanmak üzere yetkilendirdiği kişinin kullanımı içindir. Kullanıcı adı ve şifresinin "
                "üçüncü kişilere kullandırtılması durumunda, Şirket, her bir üçüncü kişi kullanımı için satın alınan "
                "hizmetin ücreti tutarında fatura düzenleyerek kullanıcıdan bu bedeli tahsil etmek hakkını haizdir. "
                "Bunun yanında, kullanıcı adı ve şifre güvenliği ile gizliliğinin korunmasından Şirket sorumlu değildir. "
                "Site üzerinde, bu kullanıcı adı ve şifrenin kullanımı sonrasında veya bununla ilgili gerçekleştirilen "
                "her türlü işlem ve faaliyetin Kullanıcı tarafından gerçekleştirildiği kabul olunur. Bu faaliyetler "
                "nedeniyle doğabilecek hukuki veya cezai bir sorumluluk Kullanıcıya aittir.\n\n"
                "3.5. Kullanıcı, hizmetleri, hizmetlerin oluşturulma amacına uygun ve hukuka uygun amaçlarla kullanmak "
                "ve kullanıma ilişkin Sitede yer verilen ilanları takip etmek zorundadır.\n\n"
                "3.6. Kullanıcı, muhtelif zamanlarda hizmetleri kullanması için üçüncü bir kişiyi veya bir çalışanını "
                "yetkilendirebilir. Kullanıcı, bu kişinin de işbu sözleşmeye ve Sitede ilan edilen talimatlara uygun "
                "olarak Rehberi kullanmasından sorumludur.\n\n"
                "3.7. Hizmetlerde yer verilen tüm bilgilerde, sunulan örneklerde, yapılan hesaplamalarda veya rehber "
                "kapsamında yararlandırılanların tümünde; hukuka uygunluk ve içeriğin doğruluğu taahhüt ve garanti "
                "edilmemekte ve hizmetlerin kullanımı ile Kullanıcı tarafından yapılan her türlü Hukuki / İdari işlemlere "
                "dair bir garanti verilmemektedir. Hizmetlerin, her bir ürün içeriğinde yer alan bilgilere uygun olarak "
                "kullanımı nedeniyle dahi doğabilecek hukuki sonuçlardan, zararlardan veya diğer tüm sorumluluk doğurucu "
                "taleplerden Şirketin hiçbir sorumluluğu bulunmamaktadır.\n\n"
                "3.8.Kullanıcı, Şirket’in dilediği içeriği hizmetlerden ve sistemlerinden kaldırabileceğini ve Şirketin "
                "kayıp veriler ve içeriğin hizmetlerden kaldırılması da dahil olmak üzere bu kapsamda meydana gelebilecek "
                "zararlardan hiçbir şekilde sorumlu olmadığını kabul eder.\n\n"
                "3.9.Kullanıcı, Site ve hizmetleri, kopyalamayacağını, uyarlamayacağını, çoğaltmayacağını, çıktı almak "
                "suretiyle yazılı bir materyal haline getirip dağıtmayacağını, Rehberdeki yazılımdan kaynak kodu "
                "oluşturmayacağını yahut hizmetlerin ve yazılımları ile yeni bir hizmet oluşması fikrini kopyalamayacağını, "
                "tersine mühendislik işlemleri yapmayacağını; kabul, beyan ve taahhüt eder.\n\n"
                "3.10. hizmetler, olağan bakım, onarım ve güncelleme zamanlarında ya da beklenmedik sistemsel sorunlarda; "
                "veya Şirket istemi dışında her hangi bir nedenle kullanım/erişim dışı kalabilecek olup; böyle durumlarda, "
                "Şirket sorunun hızlı ve efektif çözülmesi adına gereken her türlü girişimde bulunup, işlemleri yapar. "
                "Bununla birlikte bu süre zarfında hizmetlere erişimin sağlanamaması ve hizmetlerden faydalanılamaması "
                "durumunda Şirketin herhangi bir sorumluluğu doğmaz.\n\n"
                "3.11.Şirket, içerik kaybının söz konusu olmayacağına dair bir garanti vermemekte olup, içerik kaybından "
                "sorumlu değildir.\n\n"
                "3.12. Şirket ile Kullanıcı arasında gizliliğe ve kişisel verilerin korunmasına ilişkin hükümler, işbu "
                "Sözleşmeye ek niteliğinde olup, Sitede yayımlanmıştır. Taraflar bu hükümlere riayet etmeyi kabul ve "
                "taahhüt ederler.\n\n"
                "3.13. Şirket, teknik destek sunmak veya hizmetlerden azami faydanın sağlanması adına, Kullanıcı ile "
                "iletişime geçmek adına, çeşitli iletişim araçlarına Sitede yer verebilir. Bu iletişim araçlarının "
                "hukuka uygun kullanılması gerekmekte olup, aksi durum Kullanıcının sorumluluğunu doğurur. Şirketin, "
                "bu araçlar ve kullanımı nedeniyle herhangi bir sorumluluğu olmamasının yanı sıra, Şirket, Site "
                "üzerinden sağladığı iletişim araçlarını dilediği zaman kaldırma veya değiştirme hakkına da sahiptir.\n\n"
                "3.14. Şirket, işbu sözleşme ve/veya eklerini Kullanıcının rızasına gerek olmaksızın tek taraflı "
                "değiştirebilir. Değişiklik, değişikliğin ve yeni metnin Site’de yayımlanmasıyla yürürlüğe girer ve "
                "tarafları bağlar.\n\n"
                "3.15. Kullanıcı, Kullanıcı hesabını ve dolayısıyla hizmetlerin kullanımından doğan hak ve yükümlülüklerini; "
                "Şirketin onayına tabi olarak üçüncü bir kişiye devir veya temlik edebilir. Onay, Şirketin takdirine "
                "bağlıdır.\n\n"
                "3.16.Kullanıcının, işbu sözleşme ve eklerine aykırı davranışı veya hukuka aykırı eylemlerde bulunması "
                "durumunda, Şirket, Kullanıcının üyeliğini askıya alabileceği gibi sözleşmeyi de feshedebilir. "
                "Böyle bir durumda Şirketin söz konusu aykırılıktan doğan zararlarının Kullanıcıdan talep etme hakkı "
                "saklıdır.\n\n"
                "Madde 4\n"
                "Kişisel Verilerin Korunması, Ticari Elektronik İleti ve Fikri-Sinai Haklar\n"
                "4.1. 6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında kişisel veri olarak tanımlanabilecek "
                "Kullanıcı’ya ait ad, soyad, e-posta adresi, T.C. Kimlik numarası, iletişim kanalları bilgisi, adres, "
                "mali veriler vb. bilgiler; sipariş almak, ürün ve hizmetleri sunmak, ürün ve hizmetleri geliştirmek, "
                "sistemsel sorunların çözümü, ödeme işlemlerini gerçekleştirmek, siparişler, ürünler ve hizmetler "
                "hakkında pazarlama faaliyetlerinde kullanılmak, Kullanıcı’ya ait bilgilerin güncellenmesinde ve "
                "üyeliklerin yönetimi ve sürdürülmesi ile Kullanıcı ile Şirket arasında kurulan mesafeli satış "
                "sözleşmesi ve sair sözleşmelerin ifası amacıyla ve 3. kişilerin teknik, lojistik ve benzeri diğer "
                "işlevlerinin Şirket adına yerine getirilmesini sağlamak için Şirket, Şirket iştirakleri ve üçüncü kişi "
                "ve/veya kuruluşlar tarafından kaydedilebilir, yazılı/manyetik arşivlerde muhafaza edilebilir, "
                "kullanılabilir, güncellenebilir, paylaşılabilir, transfer olunabilir ve sair suretler ile işlenebilir.\n\n"
                "4.2. Kullanıcı’lara, yürürlükteki mevzuata uygun şekilde, her türlü ürün ve hizmetlere ilişkin tanıtım, "
                "reklam, iletişim, promosyon, satış ve pazarlama amacıyla, kredi kartı ve üyelik bilgilendirme, işlem, "
                "uygulamaları için SMS/kısa mesaj, anlık bildirim, otomatik arama, bilgisayar, telefon, e-posta/mail, "
                "faks, diğer elektronik iletişim araçları ile ticari elektronik iletişimler yapılabilir, Kullanıcı "
                "kendisine ticari elektronik iletiler gönderilmesini kabul etmiştir. Bu kabulü her zaman geri alabileceği "
                "konusunda aydınlatılmıştır.\n\n"
                "4.3.Kullanıcı tarafından İnternet Sitesi'nde girilen bilgilerin ve işlemlerin güvenliği için gerekli "
                "önlemler, Satıcı tarafındaki kendi sistem altyapısında, bilgi ve işlemin mahiyetine göre günümüz "
                "teknik imkanları ölçüsünde alınmıştır. Bununla beraber, söz konusu bilgiler Kullanıcı’ya ait cihazlardan "
                "girildiğinden Kullanıcı tarafından korunmaları ve ilgisiz kişilerce erişilememesi için, virüs ve benzeri"
                " zararlı uygulamalara ilişkin olanlar dahil, gerekli tedbirlerin alınması sorumluluğu Kullanıcı’ya "
                "aittir.\n\n"
                "4.4. Internet Sitesi'ne ait her türlü bilgi ve içerik ile bunların düzenlenmesi, revizyonu ve "
                "kısmen/tamamen kullanımı konusunda; Şirket’in anlaşmasına göre diğer üçüncü şahıslara ait olanlar "
                "hariç; tüm fikri-sınai haklar ve mülkiyet hakları  Yılmaz Uzun Mekanik Tasarım ve Üretim Tic. "
                "A.Ş.ye aittir.\n\n"
                "4.5. Internet Sitesi'nden ulaşılan diğer sitelerde kendilerine ait gizlilik-güvenlik politikaları ve "
                "kullanım şartları geçerlidir, oluşabilecek ihtilaflar ile menfi neticelerinden Şirket sorumlu değildir.\n\n"
                "4.6. Şirket Site ve hizmetler üzerindeki her türlü hak ve menfaatin sahibidir. İşbu Sözleşme kapsamında "
                "Kullanıcıya Site ve hizmetleri sadece kullanmak ve faydalanmak üzere kişiye özel, telifsiz, "
                "devredilemez ve münhasır olmayan bir kullanım izni verilmektedir. Sözleşme ve eklerindeki hiçbir "
                "hüküm Site ve hizmetlere ilişkin hakların ve menfaatlerin kısmen dahi olsa Kullanıcıya devredildiği "
                "şeklinde yorumlanamaz. Kullanıcı, işbu sözleşme kapsamında Şirkete,Kullanıcıların satın aldığı "
                "hizmet/hizmetlere erişimi ,kullanması ve hizmetlerin sağlanmasına yönelik diğer amaçlarla, kendisine "
                "ait bilgilerinin ve içeriğin kullanılması, kopyalanması, iletilmesi, saklanması ve yedeğinin alınması "
                "için kullanım hakkı tanımaktadır. Şirket, hizmetlerin sağlanması amacıyla içeriğe ilişkin olarak "
                "üçüncü kişi geliştiricilere alt lisans verme hakkına haizdir.\n\n"
                "4.7. Kullanıcı, hiçbir şekilde ve nedenle Siteyi veya hizmetleri kopyalama, değiştirme, çoğaltma, ters "
                "mühendisliğe tabi tutma, geri derleme ve sair şekillerde Site üzerindeki yazılımın kaynak koduna "
                "ulaşma, Siteden işleme eser oluşturma hakkına sahip değildir. Siteye ilişkin tarayıcı ve içeriklerin "
                "herhangi bir şekilde değiştirilmesi, Şirket’in açık izni olmaksızın Siteye veya Siteden link verilmesi "
                "kesinlikle yasaktır.\n\n"
                "4.8. Kullanıcı, herhangi bir şekilde Şirket’in (veya bağlı şirketlerinin) ticari unvanını, markasını, "
                "logosunu, alan adını, şablonunu kullanamayacağı gibi, Şirket ve hizmetleriyle bağlantılı veya benzer "
                "görünebilecek hiçbir eylemde de bulunamaz.\n\n"
                "Madde 5\n"
                "Sorumluluğun Sınırlandırılması\n"
                "5.1. Hizmetler içinde,\n"
                "a.AHKAM DEFTERİ uygulaması için gerekli amacın yerine getirilmesi, avukatların vekaletlerini sunduğu "
                "dosyaların ;dosya no/ esas no bilgileri ,taraf bilgileri , görevli ve yetkili mahkeme bilgileri, "
                "mahkemenin hangi aşamada olduğunu göstermek için tutulan takvim, ajanda vb. hizmetlerini "
                "kullanıcılara sunan ve  sunduğu diğer hizmetlerden yararlanılması   amacı taşımaktadır.\n"
                "b. Ahkam Defteri uygulaması hizmet ilişkileri bakımından bir rehber amacı taşımamaktadır.\n"
                "c. Ahkam Defteri yürürlükte bulunan 6698 Sayılı Kişisel Verilerin Korunması Kanunu ve ilgili alt "
                "mevzuatı esas alınarak hazırlanmıştır. Şirket, bu ürününün Çalışanların Kişisel Verilerini Koruma "
                "Uyum işlemleri ve genel anlamda ‘Veri Sorumlusu’ uyum işlemleri alanıyla ilgili bir rehber olarak "
                "kullanılmasını tavsiye etmektedir.\n\n"
                "5.2. Site kapsamındaki içerikler, hazırlayanların bilgi ürünü olup, sübjektif nitelikte ve olduğu gibi "
                "sunulmaktadır. Bu kapsamda, Şirket’in hizmetlerin, yazılım ve içeriğin doğruluğu, güvenilirliği, "
                "eksiksiz olduğu/tamlığı ile ilgili herhangi bir sorumluluk ya da taahhüdü bulunmamaktadır. "
                "İçeriklerin uygulanabilirliği, güvenilirliği, doğruluğu, tamlığı ve size uygunluğu konusunda bir "
                "avukattan görüş alınması gerekir.\n\n"
                "5.3. Şirket, hizmetin kullanımının kesintisiz ve hatasız olacağını taahhüt etmemektedir. Şirket, her "
                "ne kadar hizmetlerin yedi gün ve yirmi dört saat kullanılabilir olmasını hedeflemekte ise de "
                "hizmetlere ve Siteye erişimi sağlayan sistemlerin doğru ve efektif çalışacağına ve daima Kullanıcı "
                "tarafından erişilebilir olacağına dair bir garanti vermemektedir. Kullanıcı, Siteye ve Ürünlere "
                "erişimin zaman zaman engellenebileceğini ya da direk Ürünlere erişimin kesilebileceği-kesintiye "
                "uğratılabileceğini/uğrayabileceğini kabul eder. Şirket, söz konusu engelleme veya kesintilerden veya "
                "bunların doğuracağı doğrudan ve/veya dolaylı zararlardan hiçbir şekilde sorumlu değildir.\n\n"
                "5.4. Şirket tarafından Site üzerinden başka internet sitelerine veya kaynaklara link verilebilir. "
                "Bu durum, hiç bir şekilde, bu tür linklerin yöneldiği internet sitesini veya işleten kişisini veya "
                "kaynakları desteklemek amacı taşımayacağı gibi internet sitesi, kaynaklar veya içerdiği bilgilere "
                "yönelik herhangi bir türde bir beyan veya garanti verildiği anlamına da gelmez. Söz konusu linkler "
                "vasıtasıyla erişilen portallar, internet siteleri, kaynaklar dosyalar ve içerikler, hizmetler veya "
                "ürünler vb. veya bunların içeriği hakkında Şirket’in herhangi bir sorumluluğu bulunmamaktadır.\n\n"
                "5.5. Kullanıcı, site ve hizmetlerin kullanımından münhasıran sorumludur. Kullanıcı, fikri mülkiyet "
                "ihlalleri, içerik, hizmetler ve Sitenin kullanımına ilişkin olarak üçüncü kişiler tarafından "
                "iletilebilecek her türlü iddia ve talepten (yargılama masrafları ve avukatlık ücretleri de dahil "
                "olmak üzere) şirketi sorumsuz kabul ettiğini; Şirketin bu nedenle üçüncü kişilere ödemek durumunda "
                "kalabileceği her hangi bir tazminatı derhal ve nakden Şirkete ödeyeceğini kabul, beyan ve taahhüt eder.\n\n"
                "5.6. Şirket, uygulanacak hukukun izin verdiği ölçüde, kar kaybı, şerefiye ve itibar kaybı, ikame ürün ve "
                "hizmet temini için yapılan harcama gibi kalemler de dahil ancak bunlarla sınırlı olmaksızın Sitenin "
                "kullanımı neticesinde meydana gelen hiçbir doğrudan, dolaylı, özel, arızi, cezai zarardan sorumlu "
                "olmayacaktır. Buna ek olarak Şirket, zımni garanti, ticarete elverişlilik, belli bir amaca uygunluk da "
                "dahil ancak bunlarla sınırlı olmamak üzere, açık veya zımni hiç bir türlü garanti vermediğini de ayrıca "
                "beyan eder. Şirketin işbu sözleşme kapsamındaki sorumluluğu her halükarda ilgili zararın doğduğu tarihe "
                "kadar kullanıcı tarafından işbu sözleşmeye konu hizmetler kapsamında Şirkete ödediği tutarla sınırlı "
                "olacaktır. Bu tutarı aşan zararlar bakımından Kullanıcı Şirkete bir talep yöneltemez. Bu tutarı aşan "
                "zararlar bakımından Kullanıcı, haklarından feragat etmektedir.\n\n"
                "Madde 6\n"
                "Sözleşme’nin Yürürlüğü ve Feshi\n"
                "6.1. İşbu Sözleşme, sözleşmenin elektronik ortamda Kullanıcı tarafından kabul edilmesiyle birlikte "
                "yürürlüğe girecek ve taraflardan herhangi biri tarafından aşağıda belirtilen şekilde feshedilmediği "
                "sürece yürürlükte kalacaktır.\n"
                "6.2. Taraflardan herhangi biri, diğer tarafça bildirilen elektronik posta adresine 1 (bir) hafta önceden "
                "yapacağı yazılı bir bildirimle işbu Sözleşmeyi dilediği zaman ve herhangi bir gerekçe göstermeksizin ve "
                "tazminat ödemeksizin feshedebilecektir. Kullanıcılar üyeliğini üçüncü bir kişiye devredemeyecektir.\n\n"
                "6.3. Taraflardan birinin işbu Sözleşmeden kaynaklanan yükümlülüklerini tam ve gereği gibi yerine "
                "getirmemesi veya hukuka aykırı hareket etmesi halinde, diğer tarafça yapılacak yazılı bildirime "
                "karşın söz konusu ihlal veya aykırılık azami 15 gün içerisinde giderilmez ise, Sözleşme, bildirimi "
                "yapan tarafça feshedilebilecektir. Bahsi geçen ihlal veya aykırılığın Kullanıcı tarafından "
                "gerçekleştirilmesi halinde Şirket ihlal veya aykırılık giderilene kadar Kullanıcı statüsünü askıya "
                "alma hakkına sahip olacaktır.\n\n"
                "6.4. Sözleşmenin feshi Tarafların fesih tarihine kadar doğmuş olan hak ve yükümlülüklerini ortadan kaldırmaz.\n\n"
                "Madde 7\n"
                "Muhtelif Hükümler\n"
                "7.1. İşbu Sözleşme ekleri ile bir bütündür. İşbu Sözleşme’nin herhangi bir hükmünün veya sözleşmede yer "
                "alan herhangi bir ifadenin geçersizliği, yasaya aykırılığı ve uygulanamazlığı, Sözleşme’nin diğer "
                "hükümlerinin yürürlüğünü ve geçerliliğini etkilemeyecektir.\n\n"
                "7.2. Kullanıcı ile Şirket arasındaki iletişim Kullanıcı tarafından kayıt olurken bildirilen e-mail "
                "adresi vasıtasıyla veya Sitede yer alan genel bilgilendirme aracılığıyla yapılır. E-mail ile yapılan "
                "iletişim yazılı iletişimin yerini tutar. E-mail adresini güncel tutmak ve Siteyi bilgilendirmeler için "
                "düzenli kontrol etmek Kullanıcının sorumluluğundadır. Taraflar arasında yapılan tüm e-posta yazışmaları "
                "veya diğer iletişim araçlarıyla yapılan yazışmalar, yazılı delil niteliğindedir.\n\n"
                "7.3. İşbu Sözleşme ve eklerinden kaynaklı uyuşmazlıklarda Elazığ Mahkemeleri ve İcra Daireleri yetkilidir.\n\n",
                style: TextStyle(color: Colors.white60),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Kapat',
                style: TextStyle(
                    color: Colors.white), // Buton metnini beyaz yapıyoruz
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    // Boşlukları kırp
    _nameController.text = _nameController.text.trim();
    _surnameController.text = _surnameController.text.trim();
    _emailController.text = _emailController.text.trim();
    _passwordController.text = _passwordController.text.trim();
    _confirmPasswordController.text = _confirmPasswordController.text.trim();

    setState(() {
      _nameError = validateName(_nameController.text);
      _surnameError = validateSurname(_surnameController.text);
      _emailError = validateEmail(_emailController.text);
      _passwordError = validatePasswords(
          _passwordController.text, _confirmPasswordController.text);
    });

    if (_nameError == null &&
        _surnameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _kvkkApproved &&
        _infoApproved) {
      createPerson().then((response) {
        if (response.statusCode == 200) {
          // Kayıt başarılı mesajını göster
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt Başarılı')),
          );
        } else {
          // Hata mesajını göster
          ScaffoldMessenger.of(context).showSnackBar(
            //const SnackBar(content: Text('Kayıt başarısız. Lütfen tekrar deneyin.')),
            const SnackBar(content: Text('Kayıt Başarılı')),
          );
        }

        // Kayıttan sonra giriş yap formunu göster
        setState(() {
          _showSignIn = true;
          _showSignUp = false;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen zorunlu alanları doldurunuz.")),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_showSignIn) {
            setState(() {
              _showSignIn = false;
            });
          }
          if (_showSignUp) {
            setState(() {
              _showSignUp = false;
            });
          }
        },
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < 0) {
            // Yukarı kaydırma işlemi
            if (!_showSignIn && !_showSignUp) {
              // Eğer giriş yap ve kaydol açık değilse, ilk yukarı kaydırmada giriş yap alanı açılacak
              setState(() {
                _showSignIn = true;
                _showSignUp = false;
              });
            } else if (_showSignUp) {
              // Eğer kaydol alanı açıkken yukarı kaydırılırsa, kaydol alanı kapanacak ve login ekranı (Ahkam Defteri) gösterilecek
              setState(() {
                _showSignUp = false;
              });
            }
          } else if (details.delta.dy > 0) {
            // Aşağı kaydırma işlemi
            if (_showSignIn) {
              // Eğer giriş yap alanı açıkken aşağı kaydırılırsa, giriş yap alanı kapanacak ve Ahkam Defteri ekranı geri gelecek
              setState(() {
                _showSignIn = false;
              });
            } else if (!_showSignIn && !_showSignUp) {
              // Eğer giriş yap ve kaydol açık değilse, ikinci kez aşağı kaydırmada kaydol alanı açılacak
              setState(() {
                _showSignUp = true;
              });
            }
          }
        },
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: _showSignIn || _showSignUp ? -160 : 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/launch-image-2.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.98),
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.98),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: _showSignIn || _showSignUp
                  ? MediaQuery.of(context).size.height * 0.2
                  : MediaQuery.of(context).size.height * 0.65,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Sola yaslar
                children: [
                  Text(
                    _showSignIn || _showSignUp ? "Merhaba" : "Ahkam Defteri",
                    style: GoogleFonts.merriweather(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _showSignIn
                        ? "Seni Burada Görmek Güzel"
                        : _showSignUp
                            ? "Kaydol ve Aramıza Katıl!"
                            : "Detayları Güvenli Şekilde Hatırlamak İçin Kaydır",
                    style: GoogleFonts.merriweather(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showSignIn = !_showSignIn;
                    _showSignUp = false;
                  });
                },
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation.value),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Image.asset(
                          "assets/swipe-up-icon.png",
                          width: 50,
                          height: 50,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              bottom:
                  _showSignIn ? 0 : -MediaQuery.of(context).size.height * 0.55,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0) {
                    setState(() {
                      _showSignIn =
                          false; // İlk kaydırma ile giriş yap alanı kapanır
                      //-----------------------------------------------------------
                      _showSignUp = false;
                    });
                  }
                },
                onTap: () {},
                child: Container(
                  // height: MediaQuery.of(context).size.height * 0.55, // Yükseklik ayarını kaldırıyoruz
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF060606).withOpacity(1.0),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // İçeriğe göre boyutlanacak
                      children: [
                        const SizedBox(height: 11),
                        Container(
                          height: 3,
                          width: 80,
                          color: Colors.white30,
                          margin: const EdgeInsets.only(bottom: 20),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Giriş Yap",
                          style: GoogleFonts.merriweather(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Kaydırılabilir alan başlıyor
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _validateemailController,
                                validator: _validateEmail,
                                decoration: const InputDecoration(
                                  labelText: "E-Posta",
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFD72323)),
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _validatepasswordController,
                                obscureText:
                                    !_userpasswordVisible, // Şifreyi gizle/göster kontrolü _userpasswordVisible ile yapılacak
                                decoration: InputDecoration(
                                  labelText: "Şifre",
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFD72323)),
                                  ),
                                  // Şifre göster/gizle butonu
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _userpasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _userpasswordVisible =
                                            !_userpasswordVisible; // Şifre görünürlüğünü değiştir
                                      });
                                    },
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Parolanızı mı unuttunuz?",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Kaydırılabilir alan bitiyor
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            await performLogin();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD72323),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 15),
                          ),
                          child: const Text(
                            "Giriş Yap",
                            style: TextStyle(
                              color: Color(0xFF111111),
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showSignUp = true;
                              _showSignIn = false;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.white),
                              children: <TextSpan>[
                                const TextSpan(
                                  text: "Hesabınız yok mu? ",
                                  style: TextStyle(fontSize: 12),
                                ),
                                TextSpan(
                                  text: "Kaydol!",
                                  style: const TextStyle(
                                    color: Color(0xFFD72323),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_showSignUp)
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: MediaQuery.of(context).size.height *
                      0.75, // Yükseklik ekranın %60'ı olarak ayarlandı
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF060606).withOpacity(1.0),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 36),
                      Container(
                        color: Colors.white30,
                        margin: const EdgeInsets.only(bottom: 20),
                      ),
                      Text(
                        "Kaydol",
                        style: GoogleFonts.merriweather(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Kaydırılabilir alan başlıyor
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: "İsim",
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14, // Yazı boyutu 14px
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFd72323)),
                                  ),
                                  errorText: _nameError,
                                  errorStyle:
                                      const TextStyle(color: Colors.red),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // Yazı boyutu 14px
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _surnameController,
                                decoration: InputDecoration(
                                  labelText: "Soyisim",
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14, // Yazı boyutu 14px
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFd72323)),
                                  ),
                                  errorText: _surnameError,
                                  errorStyle:
                                      const TextStyle(color: Colors.red),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // Yazı boyutu 14px
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: "E-Mail",
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14, // Yazı boyutu 14px
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFd72323)),
                                  ),
                                  errorText: _emailError,
                                  errorStyle:
                                      const TextStyle(color: Colors.red),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // Yazı boyutu 14px
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _passwordController,
                                obscureText: !_passwordVisible,
                                decoration: InputDecoration(
                                  labelText: "Şifre",
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14, // Yazı boyutu 14px
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFd72323)),
                                  ),
                                  errorText: _passwordError,
                                  errorStyle:
                                      const TextStyle(color: Colors.red),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // Yazı boyutu 14px
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _confirmPasswordController,
                                obscureText: !_confirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: "Şifre Tekrarı",
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14, // Yazı boyutu 14px
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFFd72323)),
                                  ),
                                  errorText: _passwordError,
                                  errorStyle:
                                      const TextStyle(color: Colors.red),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _confirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _confirmPasswordVisible =
                                            !_confirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // Yazı boyutu 14px
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _kvkkApproved,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _kvkkApproved = value!;
                                      });
                                      if (_kvkkApproved) {
                                        _showKVKKPopup(context);
                                      }
                                    },
                                    activeColor: const Color(0xFFD72323),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "KVKK metnini okudum ve onaylıyorum.",
                                      style: TextStyle(
                                        color: _kvkkApproved
                                            ? Colors.white
                                            : Colors.white38,
                                        fontSize: 12, // Yazı boyutu 14px
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _infoApproved,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _infoApproved = value!;
                                      });
                                      if (_infoApproved) {
                                        _showInfoPopup(context);
                                      }
                                    },
                                    activeColor: const Color(0xFFD72323),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Kullanıcı Sözleşmesi metnini okudum ve onaylıyorum.",
                                      style: TextStyle(
                                        color: _infoApproved
                                            ? Colors.white
                                            : Colors.white38,
                                        fontSize: 12, // Yazı boyutu 14px
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _receiveEmails,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _receiveEmails = value!;
                                      });
                                    },
                                    activeColor: const Color(0xFFD72323),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Eposta ve ileti almak istiyorum.",
                                      style: TextStyle(
                                        color: _receiveEmails
                                            ? Colors.white
                                            : Colors.white38,
                                        fontSize: 12, // Yazı boyutu 14px
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),

                      // Sabit kalan "Kaydol" butonu
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD72323),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 15),
                        ),
                        child: const Text(
                          "Kaydol",
                          style: TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
