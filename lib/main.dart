import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? gender;
  String? sensitivity;
  String? activity;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gender = prefs.getString('gender');
      sensitivity = prefs.getString('sensitivity');
      activity = prefs.getString('activity');
    });
  }

  Future<void> saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("설정 화면"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("성별"),
            DropdownButton<String>(
              value: gender,
              hint: Text("성별 선택"),
              items: ["남", "여", "기타"].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  gender = value;
                  saveSetting('gender', value!);
                });
              },
            ),
            SizedBox(height: 20),
            Text("추위/더위 민감도"),
            DropdownButton<String>(
              value: sensitivity,
              hint: Text("민감도 선택"),
              items: ["예민함", "보통", "둔함"].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  sensitivity = value;
                  saveSetting('sensitivity', value!);
                });
              },
            ),
            SizedBox(height: 20),
            Text("활동 유형"),
            DropdownButton<String>(
              value: activity,
              hint: Text("활동 선택"),
              items: ["실내", "실외"].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  activity = value;
                  saveSetting('activity', value!);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
