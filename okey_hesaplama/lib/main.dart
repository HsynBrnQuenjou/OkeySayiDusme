import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core.dart';
import 'setup_page.dart';
import 'history_page.dart';

void main() {
  runApp(const OkeySkorApp());
}

class OkeySkorApp extends StatelessWidget {
  const OkeySkorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Status bar rengini ayarla (Dark tema uyumlu)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      title: 'Okey Skor Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans', // Eğer projeye font eklerseniz aktif olur, yoksa varsayılan çalışır
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.primary,
        useMaterial3: true,
      ),
      home: const HistoryPage(),
    );
  }
}