import 'package:debtdude/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:debtdude/screens/splash_screen.dart';
import 'screens/notifications_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DebtDude',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5573F6)),
      ),
    
      home: const SplashScreen(),
    );
  }
}