import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = 'YOUR_API_KEY'; // ← 여기에 너 OpenWeatherMap API 키 입력
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// 날씨 데이터를 가져오는 함수 (서울 예시 좌표)
  static Future<Map<String, dynamic>?> getWeather(double lat, double lon) async {
    final url = Uri.parse('$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ 날씨 요청 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❗ 예외 발생: $e');
      return null;
    }
  }

  /// 온도를 기반으로 옷차림 추천
  static String getClothingRecommendation(double temp) {
    if (temp >= 27) return '민소매, 반팔, 반바지';
    if (temp >= 23) return '반팔, 얇은 셔츠';
    if (temp >= 20) return '긴팔 티셔츠, 면바지';
    if (temp >= 17) return '얇은 니트, 자켓';
    if (temp >= 12) return '맨투맨, 가디건';
    if (temp >= 8) return '코트, 두꺼운 니트';
    return '패딩, 히트텍, 목도리';
  }
}
