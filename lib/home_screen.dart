
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'recommendation_service.dart';
import 'package:what_to_wear/icon.dart';

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

  String gender = 'female';
  String sensitivity = 'normal';

  final List<String> regionList = ['서울', '부산', '대구', '인천', '용인', '광주', '대전', '울산', '세종', '제주'];
  final List<String> dayList = ['오늘', '내일'];

  final Map<String, String> cityNameMap = {
    '서울': 'Seoul',
    '부산': 'Busan',
    '대구': 'Daegu',
    '인천': 'Incheon',
    '용인': 'Yongin',
    '광주': 'Gwangju',
    '대전': 'Daejeon',
    '울산': 'Ulsan',
    '세종': 'Sejong',
    '제주': 'Jeju',
  };

  List<String> outfitItems = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    fetchWeatherData();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settingsBox');
    gender = box.get('gender', defaultValue: 'female');
    sensitivity = box.get('sensitivity', defaultValue: 'normal');
  }

  Future<void> fetchWeatherData() async {
    final city = cityNameMap[selectedRegion] ?? 'Seoul';
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=ffd32dd080a6c417a7920d318e4ee992&units=metric'));
    final data = jsonDecode(response.body);

    setState(() {
      temperature = data['main']['temp'];
      feelsLike = data['main']['feels_like'];
      wind = data['wind']['speed'];
      rain = data['rain'] != null ? data['rain']['1h'] ?? 0 : 0;

      final outfit = recommendOutfit(
        region: selectedRegion,
        day: selectedDay,
        temp: feelsLike,
        condition: data['weather'][0]['main'],
      );
      outfitItems = outfit.split(',').map((e) => e.trim()).toList();
    });
  }

  Widget _dropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        isExpanded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('오늘 뭐 입지?')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _dropdown(selectedRegion, regionList, (v) {
                      setState(() {
                        selectedRegion = v!;
                        fetchWeatherData();
                      });
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdown(selectedDay, dayList, (v) {
                      setState(() {
                        selectedDay = v!;
                        fetchWeatherData();
                      });
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 0),
              SizedBox(
                height: screenHeight * 0.35,
                width: double.infinity,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: const Color(0xFFF9F6FF),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${temperature.toStringAsFixed(1)}℃',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text('체감 온도: ${feelsLike.toStringAsFixed(1)}℃', style: const TextStyle(fontSize: 16)),
                        Text('강수량: ${rain.toStringAsFixed(1)} mm', style: const TextStyle(fontSize: 16)),
                        Text('바람: ${wind.toStringAsFixed(1)} m/s', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 0),
              SizedBox(
                height: screenHeight * 0.35,
                width: double.infinity,
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: const Color(0xFFF9F6FF),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('추천 옷차림', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: outfitItems.map((item) => WeatherIcon(itemName: item)).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
