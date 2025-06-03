
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'recommendation_service.dart';
import 'weather_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with AutomaticKeepAliveClientMixin {
  DateTime selectedDay = DateTime.now();
  String recommendation = '';
  String region = '서울';

  final Map<String, String> recommendationIcons = {
    '민소매': 'assets/sleeveless.png',
    '반팔': 'assets/short_sleeve.png',
    '긴팔': 'assets/long_sleeve.png',
    '후디': 'assets/hoodie.png',
    '스웨터': 'assets/sweater.png',
    '자켓': 'assets/jacket.png',
    '가디건': 'assets/cardigan.png',
    '긴바지': 'assets/long_pants.png',
    '반바지': 'assets/short_pants.png',
    '롱스커트': 'assets/long_skirts.png',
    '원피스': 'assets/onepiece.png',
    '우산': 'assets/umbrella.png',
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettingsAndWeather();
    });
  }

  Future<void> _loadSettingsAndWeather() async {
    final box = Hive.box('settingsBox');
    region = box.get('region', defaultValue: '서울');

    final weather = await fetchWeatherWithDetails(region, selectedDay);
    setState(() {
      recommendation = recommendOutfit(
        region: region,
        day: _getDayString(selectedDay),
        temp: weather['feelsLike'],
        condition: weather['condition'],
      );
    });
  }

  void _onDateSelected(DateTime date) async {
    final box = Hive.box('settingsBox');
    region = box.get('region', defaultValue: '서울');

    final weather = await fetchWeatherWithDetails(region, date);
    setState(() {
      selectedDay = date;
      recommendation = recommendOutfit(
        region: region,
        day: _getDayString(date),
        temp: weather['feelsLike'],
        condition: weather['condition'],
      );
    });
  }

  String _getDayString(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '오늘';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day + 1) {
      return '내일';
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentMonth = List.generate(31, (index) {
      try {
        return DateTime(selectedDay.year, selectedDay.month, index + 1);
      } catch (_) {
        return null;
      }
    }).whereType<DateTime>().toList();

    final items = recommendation.split(',').map((e) => e.trim()).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              '지역: $region',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 260,
              child: GridView.count(
                crossAxisCount: 7,
                padding: const EdgeInsets.all(8),
                children: currentMonth.map((date) {
                  return GestureDetector(
                    onTap: () => _onDateSelected(date),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: date.day == selectedDay.day ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: date.day == selectedDay.day ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${selectedDay.month}월 ${selectedDay.day}일 추천 옷차림',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: items.map((item) {
                            final iconPath = recommendationIcons[item];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                iconPath != null
                                    ? Image.asset(iconPath, width: 50, height: 50)
                                    : const Icon(Icons.help_outline),
                                const SizedBox(height: 4),
                                Text(item, style: const TextStyle(fontSize: 12)),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
