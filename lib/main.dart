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

  Widget _buildCard(String title, Widget dropdown) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            dropdown,
          ],
        ),
      ),
    );
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
              "성별",
              DropdownButton<String>(
                value: gender,
                hint: Text("성별 선택"),
                isExpanded: true,
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
            ),
            _buildCard(
              "추위/더위 민감도",
              DropdownButton<String>(
                value: sensitivity,
                hint: Text("민감도 선택"),
                isExpanded: true,
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
            ),
            _buildCard(
              "활동 유형",
              DropdownButton<String>(
                value: activity,
                hint: Text("활동 선택"),
                isExpanded: true,
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
            ),
          ],
        ),
      ),
    );
  }
}
