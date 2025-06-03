import 'package:flutter/material.dart';

// 기존 iconCategories 그대로 유지
final Map<String, Map<String, String>> iconCategories = {
  '상의': {
    '민소매': 'assets/sleeveless.png',
    '반팔': 'assets/short_sleeve.png',
    '긴팔': 'assets/long_sleeve.png',
    '후디': 'assets/hoodie.png',
    '스웨터': 'assets/sweater.png',
  },
  '하의': {
    '긴바지': 'assets/long_pants.png',
    '반바지': 'assets/short_pants.png',
    '롱스커트': 'assets/long_skirts.png',
  },
  '한벌옷': {
    '원피스': 'assets/onepiece.png',
  },
  '아우터': {
    '자켓': 'assets/jacket.png',
    '가디건': 'assets/cardigan.png',
  },
  '기타': {
    '우산': 'assets/umbrella.png',
  },
};

// 공통 위젯 함수
Widget buildItemIcon(String item, double size) {
  for (final category in iconCategories.values) {
    if (category.containsKey(item)) {
      return Image.asset(category[item]!, width: size, height: size);
    }
  }
  return Column(
    children: [
      Icon(Icons.help_outline, size: size),
      const SizedBox(height: 4),
      Text(item, style: TextStyle(fontSize: size * 0.3)),
    ],
  );
}

// ✅ 이걸 새로 추가! StatefulWidget에서 사용 가능한 Widget으로 래핑
class WeatherIcon extends StatelessWidget {
  final String itemName;
  final double size;

  const WeatherIcon({super.key, required this.itemName, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: buildItemIcon(itemName, size),
    );
  }
}
