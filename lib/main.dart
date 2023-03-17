import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  /*
  google_maps_flutter: ^2.2.3 ifadesini kütüphanelere ekliyoruz
  https://mapsplatform.google.com/ sitesine giriyoruz ve başlıyoruz, proje oluşturuyoruz sonra credentials alanında api kimliği oluşturuyıruz
  gelen api yi kopyalıyoruz
    AIzaSyBWjtnCrJ4aNkxqi-5EQO7NUaNlpOxycAU
    - daha fazla devam edemedim ücretli olduğu için.. örnekten devam
    Google Maps platforma geliyoruz->Maps SDK Android i seçip etkinleştiriyoruz
    Api lerden MAps sdk for ios tan ios için kurulum  yapıyoruz ve etkinleştiriyoruz
    ilgili api keyini
     android için;
     app/src/android.manifest doyasında <application içine  <aactivity den önce
    <meta-data android:name="com.google.android.geo.API_KEY"
      android:value="buraya kopyaladığımız API key ini yapıştırıyoruz"/>
      compileSdkVersion 31
      minSdk 21
      target 31
      ios için;
      ios/Runner/AppDlegate.swift dosyasını açıyoeruz
      import alanlarının altına
      import GoogleMaps i ekliyoeruz
      daha sonra aynı dosyada -> Bool{ yazan yerin içine en üste
      GMSServices.provideAPIKey("yine kopyaladığımız apı keyini buraya yapıştırıyoruz")

      ios/Runner/info.plist te ios için izin alacağız
      en altına true veya false tan sonra
      <key>io.flutter.embedded_views_preview</key>
      <string>YES</string>
      olarak ekliyoruz.

   */

  late BitmapDescriptor konumIcon; // marker özelleştirme

  Completer<GoogleMapController> haritaKontrol = Completer(); // sayesinde haritayı kontrol edebileceğiz

  // haritanın başlangıç konumu zoom miktarı gibi bilgileri belirtememiz gerekiyor
  var baslangicKonum = CameraPosition(target: LatLng(38.7412482, 26.1844276), zoom: 4,); // enlem boylam tr için yani tr yi gösteriyor

  // icon oluşturma
  iconOlusturma(context){ // context bu sayfayı tanımlayan ifadedir
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    BitmapDescriptor.fromAssetImage(configuration, "resimler/AppIcon76x76.png").then((icon) {
      konumIcon = icon;
    });
  }

  // 2.ders konuma gitme ve buton oluşturup Future özelliği olan bir metot tanımlayacağız
  Future<void> konumaGit() async{
    GoogleMapController controller = await haritaKontrol.future; // bir tane kontrol nesnesi oluşturduk

    //aynı konuma bir tane işaret ekleyeceğiz
    var gidilecekIsaret = Marker(
      //ÖZELLİKler ekleyeceğiz
      markerId: MarkerId("Id"), // birden fazla marker olabileceği için id vereceğiz
      position: LatLng(41.0039643, 28.4517462), // marker ın konulacağı konum bilgisini belirtiyoruz
      infoWindow: InfoWindow(title: "İstanbul", snippet: "Evim"), //Marker a bilgiler ekleyebiliriz
      icon: konumIcon,
    );

    setState(() {
      isaretler.add(gidilecekIsaret); // butona bastığımız anda Future içerisinden işaretlenen yeri alacak
    });

    var gidilecekKonum = CameraPosition(target: LatLng(41.0039643, 28.4517462), zoom: 8,); // istanbulun konum bilgisi
    controller.animateCamera(CameraUpdate.newCameraPosition(gidilecekKonum)); // controller ile gidilecekKonum u bağladık
    // , metotların camera olarak yazılma sebebi haritanın etrafındaki çerçeveyi öyle tanımlamaları ve geçişinde sanki camerayla oluyormuş gibi tanımlamalar yapmışlar
  }

  // 3.ders marker işaret ekleme
  List<Marker> isaretler = <Marker>[]; // merkerları liste içerisinde tutuyoruz

  @override
  Widget build(BuildContext context) {
    iconOlusturma(context); // metodu burada çalıştırmamız gerekiyor ki özelleştirilmiş marker ı kullanabilelim.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // mainAxis i siliyoruz çünkü haritayı yukarıda görmek istiyoruz, eğer kullanırsak ortalı olarak gelecektir
          children: <Widget>[
            SizedBox( // haritayı boyutlandırmak istedik
              width: 400, height: 300,
              child: GoogleMap(
                initialCameraPosition: baslangicKonum,

                // 3. ders marker ekleme, oluşturduğumuz listeyi googlaMap e ekliyoruz
                markers: Set<Marker>.of(isaretler), // ve 2. derste eklediğimiz gidilecek konuma işaret ekleyeceğiz

                mapType: MapType.normal, // haritanın normal halini görürüz, eğer satellite seçersek uydu olarak gelir
                onMapCreated: (GoogleMapController controller){ // yukarıda oluşturduğumuz haritaKontrol ü bağlayacağız
                  haritaKontrol.complete(controller);
                },
              ),
            ),
            ElevatedButton(
                onPressed: (){
                  konumaGit();
                },
                child: Text("Konuma Git"),
            )
          ],
        ),
      ),
    );
  }
}
