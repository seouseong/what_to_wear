import 'package:hive/hive.dart';

String recommendOutfit({
  required String region,
  required String day,
  required double temp,
  required String condition,
}) {
  final settingsBox = Hive.box('settingsBox');

  final String gender = settingsBox.get('gender', defaultValue: '남성');
  final double sensitivity = settingsBox.get('sensitivity', defaultValue: 0.5);
  final String activity = settingsBox.get('activity', defaultValue: '보통');

  List<String> outfit = [];

  // 활동량에 따른 체감온도 보정값
  double activityAdjustment = 0.0;
  if (activity == '보통') {
    activityAdjustment = 1.0;
  } else if (activity == '많음') {
    activityAdjustment = 2.0;
  }

  // 민감도 및 활동량 반영한 최종 기온 보정
  double adjustedTemp = temp - ((sensitivity - 0.5) * 10) + activityAdjustment;

  // 날씨 조건 처리
  if (condition == 'Rain') {
    outfit.add('우산');
  }

  // 상의 추천
  if (adjustedTemp <= 5) {
    outfit.addAll(['후디', '스웨터', '자켓']);
  } else if (adjustedTemp <= 15) {
    outfit.addAll(['긴팔', '가디건']);
  } else if (adjustedTemp <= 22) {
    outfit.add('반팔');
  } else {
    outfit.addAll(['반팔', '민소매']);
  }

  // 하의 추천
  if (adjustedTemp >= 23) {
    outfit.add('반바지');
  } else if (adjustedTemp >= 15) {
    if (gender == '여성') {
      outfit.add('롱스커트');
    } else {
      outfit.add('긴바지');
    }
  } else {
    outfit.add('긴바지');
  }

  // 한벌옷 추천 (여성만)
  if (adjustedTemp >= 20 && adjustedTemp <= 27 && gender == '여성') {
    outfit.add('원피스');
  }

  return outfit.join(', ');
}
