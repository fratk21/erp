import 'package:erp_station/app/view/bottombar/bottommenu.dart';
import 'package:erp_station/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  await Hive.openBox('settings');
  await DataService().start(); // 🧠 veri servisi başlatılıyor

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white, // Sayfa zemin rengi

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // AppBar beyaz
          foregroundColor: Colors.black, // Yazı ve ikonlar siyah
          elevation: 1, // Hafif gölge
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: NavigationMainPage(),
    );
  }
}
