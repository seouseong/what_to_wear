
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String gender = '남성';
  double sensitivity = 0.5;
  String activity = '보통';

  final List<String> genders = ['남성', '여성'];
  final List<String> activities = ['적음', '보통', '많음'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = Hive.box('settingsBox');
    setState(() {
      gender = box.get('gender', defaultValue: '남성');
      sensitivity = box.get('sensitivity', defaultValue: 0.5);
      activity = box.get('activity', defaultValue: '보통');
    });
  }


  Future<void> _saveSettings() async {
    final box = Hive.box('settingsBox');
    box.put('gender', gender);
    box.put('sensitivity', sensitivity);
    box.put('activity', activity);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('설정', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  const Text('성별'),
                  DropdownButton<String>(
                    value: gender,
                    items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (value) {
                      setState(() => gender = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('온도 민감도'),
                  Slider(
                    value: sensitivity,
                    onChanged: (value) {
                      setState(() => sensitivity = value);
                    },
                    min: 0,
                    max: 1,
                    divisions: 10,
                    label: sensitivity.toStringAsFixed(1),
                  ),
                  const SizedBox(height: 16),
                  const Text('활동량'),
                  DropdownButton<String>(
                    value: activity,
                    items: activities.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                    onChanged: (value) {
                      setState(() => activity = value!);
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      child: const Text('저장하기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
