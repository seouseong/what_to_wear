  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:hive_flutter/hive_flutter.dart';
  import 'package:hive/hive.dart';
  import 'package:what_to_wear/models/clothing_item.dart';

  class ClosetScreen extends StatefulWidget {
    @override
    State<ClosetScreen> createState() => _ClosetScreenState();
  }

  class _ClosetScreenState extends State<ClosetScreen> {
    final TextEditingController _nameController = TextEditingController();
    final List<String> _categories = ['상의', '하의', '한벌옷', '아우터', '기타'];
    String _selectedCategory = '상의';
    String? _selectedIcon;
    String? _imagePath;
    final ImagePicker _picker = ImagePicker();

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

    late Box<ClothingItem> clothingBox;

    @override
    void initState() {
      super.initState();
      clothingBox = Hive.box<ClothingItem>('clothingBox');
    }

    Future<void> _pickImage(ImageSource source) async {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    }

    Future<void> _addItem() async {
      if (_nameController.text.trim().isEmpty || (_selectedIcon == null && _imagePath == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('옷 이름과 사진 또는 아이콘을 선택해주세요.')),
        );
        return;
      }

      final item = ClothingItem(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        imagePath: _imagePath ?? _selectedIcon ?? '',
      );

      await clothingBox.add(item);

      setState(() {
        _nameController.clear();
        _selectedIcon = null;
        _imagePath = null;
      });
    }

    Future<void> _deleteItem(int index) async {
      await clothingBox.deleteAt(index);
      setState(() {});
    }

    @override
    Widget build(BuildContext context) {
      final iconMap = iconCategories[_selectedCategory]!;

      return Scaffold(
        appBar: AppBar(title: Text('옷장')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '옷 이름',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: iconMap.entries.map((entry) {
                    final selected = _selectedIcon == entry.value;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = entry.value),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: selected ? Colors.blue : Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Image.asset(entry.value, width: 48, height: 48),
                            Text(entry.key, style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('카메라'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo),
                    label: Text('갤러리'),
                  ),
                  if (_imagePath != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Image.file(File(_imagePath!), width: 48, height: 48),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addItem,
                child: Text('등록'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: clothingBox.listenable(),
                  builder: (context, Box<ClothingItem> box, _) {
                    if (box.isEmpty) return Center(child: Text('등록된 옷이 없습니다.'));
                    return ListView.builder(
                      itemCount: box.length,
                      itemBuilder: (context, index) {
                        final item = box.getAt(index);
                        final fileExists = item != null && File(item.imagePath).existsSync();
                        return Card(
                          child: ListTile(
                            leading: fileExists
                                ? Image.file(File(item!.imagePath), width: 48, height: 48)
                                : Icon(Icons.image_not_supported),
                            title: Text(item?.name ?? ''),
                            subtitle: Text(item?.category ?? ''),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteItem(index),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
