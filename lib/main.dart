import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'AnaEkran.dart';
import 'GirişYap.dart';
import 'Modeller/ProviderHelper.dart';
import 'Modeller/splash.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StateHelper()),
      ],
      child:  MaterialApp(
        title: "Dream WMS",
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),Locale('tr', '') // English and Turkish
          // ... other locales the app supports
        ],
        debugShowCheckedModeBanner: false,
        home: GirisYap(),
      ),
    ),
  );
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds:  AnaEkran(),
      title: Text('Hoşgeldiniz',
        style:  TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 20.0
        ),
      ),
      image: new Image.asset('assets/images/dream_lojistik.png',),
      gradientBackground: new LinearGradient(colors: [Colors.white, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      onClick: ()=>print("Flutter Egypt"),
      loaderColor: Colors.blue.shade900,
    );
  }
}