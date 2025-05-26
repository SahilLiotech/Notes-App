import 'package:hive/hive.dart';

part 'notes_model.g.dart';

@HiveType(typeId: 0)
class NotesModel extends HiveObject {
  @HiveField(0)
  String? title;

  @HiveField(1)
  String? content;

  @HiveField(2)
  DateTime? date;

  @HiveField(3)
  String? color;

  @HiveField(4)
  String? category;

  NotesModel({
    required this.title,
    required this.content,
    required this.date,
    required this.color,
    required this.category,
  });
}
