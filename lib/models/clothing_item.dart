import 'package:hive/hive.dart';

part 'clothing_item.g.dart';

@HiveType(typeId: 0)
class ClothingItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String category;

  @HiveField(2)
  String imagePath;

  ClothingItem({
    required this.name,
    required this.category,
    required this.imagePath,
  });
}
