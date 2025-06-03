import 'dart:convert';
import 'package:http/http.dart' as http;

const apiKey = 'ffd32dd080a6c417a7920d318e4ee992';

// 지역명 -> 위도/경도 매핑
const Map<String, Map<String, double>> regionCoordinates = {
  '서울': {'lat': 37.5665, 'lon': 126.9780},
  '부산': {'lat': 35.1796, 'lon': 129.0756},
  '대구': {'lat': 35.8722, 'lon': 128.6025},
  '인천': {'lat': 37.4563, 'lon': 126.7052},
  '광주': {'lat': 35.1595, 'lon': 126.8526},
  '대전': {'lat': 36.3504, 'lon': 127.3845},
  '울산': {'lat': 35.5384, 'lon': 129.3114},
};

Future<Map<String, dynamic>> fetchWeatherWithDetails(String region, DateTime date) async {
  final coords = regionCoordinates[region] ?? regionCoordinates['서울']!;
  final lat = coords['lat'];
  final lon = coords['lon'];

  final now = DateTime.now();
  final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

  if (isToday) {
    // 오늘은 현재 날씨 API
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey&lang=kr';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    return {
      'feelsLike': data['main']['feels_like'],
      'condition': data['weather'][0]['main'],
    };
  } else {
    // 나머지는 예보 API (최대 5일치)
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey&lang=kr';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    final List forecastList = data['list'];

    // 선택한 날짜와 가장 가까운 시간대 예보 찾기
    Map<String, dynamic>? selectedForecast;
    Duration smallestDiff = const Duration(hours: 999);

    for (var item in forecastList) {
      final dtTxt = item['dt_txt']; // 예: '2025-06-03 15:00:00'
      final forecastTime = DateTime.parse(dtTxt);

      if (forecastTime.day == date.day) {
        final diff = forecastTime.difference(date).abs();
        if (diff < smallestDiff) {
          smallestDiff = diff;
          selectedForecast = item;
        }
      }
    }

    if (selectedForecast != null) {
      return {
        'feelsLike': selectedForecast['main']['feels_like'],
        'condition': selectedForecast['weather'][0]['main'],
      };
    } else {
      throw Exception('예보 데이터를 찾을 수 없습니다.');
    }
  }
}
