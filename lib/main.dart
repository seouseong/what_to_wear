import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // 홈 화면 import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘 뭐 입지?',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // 홈 화면 연결
      debugShowCheckedModeBanner: false,
    );
  }
}
