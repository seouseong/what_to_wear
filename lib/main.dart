import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart'; // ✅ 이 경로에 실제 파일이 있어야 함

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CalendarScreen(), // ✅ calendar_screen.dart 안에 const CalendarScreen 있어야 함
    );
  }
}
  