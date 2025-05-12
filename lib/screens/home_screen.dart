import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedRegion = '서울';
  String selectedDay = '오늘';

  double temperature = 0;
  double feelsLike = 0;
  double rain = 0;
  double wind = 0;
  int humidity = 0;

  String gender = 'female';
  String sensitivity = 'cold';

  final List<String> regionList = [
    '서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종'
  ];

  final List<String> dayList = ['오늘', '내일'];

  final Map<String, String> cityNameMap = {
    '서울': 'Seoul',
    '부산': 'Busan',
    '대구': 'Daegu',
    '인천': 'Incheon',
    '광주': 'Gwangju',
    '대전': 'Daejeon',
    '울산': 'Ulsan',
    '세종': 'Sejong',
    '용인': 'Yongin'
  };

  Future<void> fetchWeather() async {
    final city = cityNameMap[selectedRegion] ?? 'Seoul';
    final apiKey = 'a1bcfe537d0cc1a56a918abdf71d02a3';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = data['main']['temp'].toDouble();
          feelsLike = data['main']['feels_like'].toDouble();
          wind = data['wind']['speed'].toDouble();
          humidity = data['main']['humidity'].toInt();

          // 강수 확률은 기본 weather API에는 없고 rain 1h에 있는 경우가 있음
          rain = data['rain']?['1h']?.toDouble() ?? 0.0;
        });
      } else {
        throw Exception('불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  String recommendOutfit() {
    double adjustedFeelsLike = feelsLike;
    if (sensitivity == "cold") adjustedFeelsLike -= 2;
    if (sensitivity == "heat") adjustedFeelsLike += 2;

    String outfit = '';
    if (adjustedFeelsLike >= 27) {
      outfit = "민소매, 반팔, 반바지";
    } else if (adjustedFeelsLike >= 23) {
      outfit = "반팔, 얇은 셔츠";
    } else if (adjustedFeelsLike >= 20) {
      outfit = "긴팔 티셔츠, 면바지";
    } else if (adjustedFeelsLike >= 17) {
      outfit = "얇은 니트, 자켓";
    } else if (adjustedFeelsLike >= 12) {
      outfit = "맨투맨, 가디건";
    } else if (adjustedFeelsLike >= 8) {
      outfit = "코트, 두꺼운 니트";
    } else {
      outfit = "패딩, 히트텍, 목도리";
    }

    if (rain >= 0.1) outfit += " , 우산";
    if (wind >= 6.0) outfit += " , 바람막이";
    if (humidity >= 85 && adjustedFeelsLike >= 20) outfit += " (통풍 잘 되는 옷)";
    if (gender == "female" && adjustedFeelsLike < 15) outfit += ", 보온용 레깅스";

    return outfit;
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(); // 초기 실행 시 날씨 불러오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "오늘 뭐 입지?",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 지역 및 날짜 선택
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: selectedRegion,
                    items: regionList,
                    onChanged: (value) {
                      setState(() {
                        selectedRegion = value!;
                      });
                      fetchWeather();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    value: selectedDay,
                    items: dayList,
                    onChanged: (value) {
                      setState(() {
                        selectedDay = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 날씨 카드
            _buildCard(
              children: [
                Text(
                  "${temperature.toStringAsFixed(1)}℃",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("체감 온도: ${feelsLike.toStringAsFixed(1)}℃"),
                Text("강수량: ${rain.toStringAsFixed(1)} mm"),
                Text("바람: ${wind.toStringAsFixed(1)} m/s"),
              ],
            ),

            const SizedBox(height: 20),

            // 추천 옷차림
            _buildCard(
              children: [
                const Text("추천 옷차림",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(recommendOutfit(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Icon(Icons.checkroom, size: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Column(children: children),
      ),
    );
  }
}
