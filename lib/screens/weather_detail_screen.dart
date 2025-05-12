import 'package:flutter/material.dart';

class WeatherDetailScreen extends StatelessWidget {
  final DateTime selectedDate;

  const WeatherDetailScreen({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    // 실제 날씨 API 연결 전: 더미 데이터
    String dummyWeather = "☀️ 맑음";
    String dummyClothing = "반팔 + 반바지";

    return Scaffold(
      appBar: AppBar(title: const Text('날씨 상세 정보')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📅 선택한 날짜: ${selectedDate.toLocal().toString().split(' ')[0]}"),
            const SizedBox(height: 20),
            Text("🌤 날씨 상태: $dummyWeather"),
            Text("👕 추천 옷차림: $dummyClothing"),
          ],
        ),
      ),
    );
  }
}
