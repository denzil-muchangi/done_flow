import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tasks.dart';

class TaskProvider extends ChangeNotifier {
  late Box<Task> _taskBox;
  List<Task> _tasks = [];
  String _searchQuery = '';
  TaskCategory? _selectedCategory;
  TaskPriority? _selectedPriority;
  bool _showCompleted = true;

  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _tasks;
  String get searchQuery => _searchQuery;
  TaskCategory? get selectedCategory => _selectedCategory;
  TaskPriority? get selectedPriority => _selectedPriority;
  bool get showCompleted => _showCompleted;

  List<Task> get _filteredTasks {
    List<Task> filtered = _tasks;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) =>
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (task.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered.where((task) => task.category == _selectedCategory).toList();
    }

    // Filter by priority
    if (_selectedPriority != null) {
      filtered = filtered.where((task) => task.priority == _selectedPriority).toList();
    }

    // Filter completed tasks
    if (!_showCompleted) {
      filtered = filtered.where((task) => !task.isDone).toList();
    }

    // Sort by priority (high first), then by due date, then by creation date
    filtered.sort((a, b) {
      // Priority sorting
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }

      // Due date sorting (overdue first)
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;

      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;

      // Creation date sorting (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  Future<void> init() async {
    _taskBox = await Hive.openBox<Task>('tasks');
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _taskBox.add(task);
    await _loadTasks();
  }

  Future<void> updateTask(int index, Task updatedTask) async {
    final taskKey = _taskBox.keyAt(index);
    await _taskBox.put(taskKey, updatedTask);
    await _loadTasks();
  }

  Future<void> deleteTask(int index) async {
    final taskKey = _taskBox.keyAt(index);
    await _taskBox.delete(taskKey);
    await _loadTasks();
  }

  Future<void> toggleTask(int index) async {
    final task = _tasks[index];
    task.isDone = !task.isDone;
    await updateTask(index, task);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(TaskCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedPriority = null;
    _showCompleted = true;
    notifyListeners();
  }

  Map<TaskCategory, int> get categoryCounts {
    final counts = <TaskCategory, int>{};
    for (final category in TaskCategory.values) {
      counts[category] = _tasks.where((task) => task.category == category).length;
    }
    return counts;
  }

  Map<TaskPriority, int> get priorityCounts {
    final counts = <TaskPriority, int>{};
    for (final priority in TaskPriority.values) {
      counts[priority] = _tasks.where((task) => task.priority == priority).length;
    }
    return counts;
  }

  int get completedTasksCount => _tasks.where((task) => task.isDone).length;
  int get pendingTasksCount => _tasks.where((task) => !task.isDone).length;
  int get overdueTasksCount => _tasks.where((task) => task.isOverdue).length;

  @override
  void dispose() {
    _taskBox.close();
    super.dispose();
  }
}