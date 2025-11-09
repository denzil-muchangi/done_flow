import 'package:hive/hive.dart';

part 'tasks.g.dart';

enum TaskPriority { low, medium, high }
enum TaskCategory { work, personal, shopping, health, other }
enum RecurrenceType { none, daily, weekly, monthly, yearly }
enum TaskSortOption { priority, dueDate, createdDate, category, title }

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

  @HiveField(7)
  RecurrenceType recurrence;

  @HiveField(8)
  int? recurrenceInterval;

  @HiveField(9)
  DateTime? nextRecurrence;

  Task({
    required this.title,
    this.isDone = false,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.other,
    this.dueDate,
    this.notes,
    this.recurrence = RecurrenceType.none,
    this.recurrenceInterval = 1,
    this.nextRecurrence,
  }) : createdAt = DateTime.now();

  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
        'priority': priority.index,
        'category': category.index,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'notes': notes,
        'recurrence': recurrence.index,
        'recurrenceInterval': recurrenceInterval,
        'nextRecurrence': nextRecurrence?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isDone: json['isDone'],
        priority: TaskPriority.values[json['priority'] ?? 1],
        category: TaskCategory.values[json['category'] ?? 4],
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        notes: json['notes'],
        recurrence: RecurrenceType.values[json['recurrence'] ?? 0],
        recurrenceInterval: json['recurrenceInterval'] ?? 1,
        nextRecurrence: json['nextRecurrence'] != null ? DateTime.parse(json['nextRecurrence']) : null,
      )..createdAt = DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String());

  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isDone;

  bool get isRecurring => recurrence != RecurrenceType.none;

  DateTime? getNextRecurrenceDate() {
    if (!isRecurring || dueDate == null) return null;

    switch (recurrence) {
      case RecurrenceType.daily:
        return dueDate!.add(Duration(days: recurrenceInterval ?? 1));
      case RecurrenceType.weekly:
        return dueDate!.add(Duration(days: 7 * (recurrenceInterval ?? 1)));
      case RecurrenceType.monthly:
        return DateTime(
          dueDate!.year,
          dueDate!.month + (recurrenceInterval ?? 1),
          dueDate!.day,
        );
      case RecurrenceType.yearly:
        return DateTime(
          dueDate!.year + (recurrenceInterval ?? 1),
          dueDate!.month,
          dueDate!.day,
        );
      default:
        return null;
    }
  }
}