import 'package:hive/hive.dart';

part 'tasks.g.dart';

enum TaskPriority { low, medium, high }
enum TaskCategory { work, personal, shopping, health, other }

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  TaskPriority priority;

  @HiveField(3)
  TaskCategory category;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String? notes;

  Task({
    required this.title,
    this.isDone = false,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.other,
    this.dueDate,
    this.notes,
  }) : createdAt = DateTime.now();

  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
        'priority': priority.index,
        'category': category.index,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'notes': notes,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isDone: json['isDone'],
        priority: TaskPriority.values[json['priority'] ?? 1],
        category: TaskCategory.values[json['category'] ?? 4],
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        notes: json['notes'],
      )..createdAt = DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String());

  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isDone;
}