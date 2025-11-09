import 'dart:convert';
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
  TaskSortOption _sortOption = TaskSortOption.priority;
  bool _sortAscending = false;
  Set<int> _selectedTasks = {};
  bool _isSelectionMode = false;
  DateTimeRange? _dateRangeFilter;

  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _tasks;
  String get searchQuery => _searchQuery;
  TaskCategory? get selectedCategory => _selectedCategory;
  TaskPriority? get selectedPriority => _selectedPriority;
  bool get showCompleted => _showCompleted;
  TaskSortOption get sortOption => _sortOption;
  bool get sortAscending => _sortAscending;
  Set<int> get selectedTasks => _selectedTasks;
  bool get isSelectionMode => _isSelectionMode;
  DateTimeRange? get dateRangeFilter => _dateRangeFilter;

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

    // Filter by date range
    if (_dateRangeFilter != null) {
      filtered = filtered.where((task) {
        if (task.dueDate == null) return false;
        return task.dueDate!.isAfter(_dateRangeFilter!.start) &&
               task.dueDate!.isBefore(_dateRangeFilter!.end);
      }).toList();
    }

    // Custom sorting
    filtered.sort((a, b) {
      int result = 0;

      switch (_sortOption) {
        case TaskSortOption.priority:
          result = b.priority.index.compareTo(a.priority.index);
          break;
        case TaskSortOption.dueDate:
          if (a.dueDate == null && b.dueDate == null) result = 0;
          else if (a.dueDate == null) result = 1;
          else if (b.dueDate == null) result = -1;
          else result = a.dueDate!.compareTo(b.dueDate!);
          break;
        case TaskSortOption.createdDate:
          result = b.createdAt.compareTo(a.createdAt);
          break;
        case TaskSortOption.category:
          result = a.category.index.compareTo(b.category.index);
          break;
        case TaskSortOption.title:
          result = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
      }

      return _sortAscending ? result : -result;
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
    final wasDone = task.isDone;
    task.isDone = !task.isDone;

    // Handle recurring tasks
    if (task.isRecurring && task.isDone && !wasDone) {
      // Create next recurrence
      final nextDueDate = task.getNextRecurrenceDate();
      if (nextDueDate != null) {
        final newTask = Task(
          title: task.title,
          priority: task.priority,
          category: task.category,
          dueDate: nextDueDate,
          notes: task.notes,
          recurrence: task.recurrence,
          recurrenceInterval: task.recurrenceInterval,
        );
        await addTask(newTask);
      }
    }

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
    _dateRangeFilter = null;
    notifyListeners();
  }

  void setSortOption(TaskSortOption option) {
    if (_sortOption == option) {
      _sortAscending = !_sortAscending;
    } else {
      _sortOption = option;
      _sortAscending = false;
    }
    notifyListeners();
  }

  void setDateRangeFilter(DateTimeRange? range) {
    _dateRangeFilter = range;
    notifyListeners();
  }

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedTasks.clear();
    }
    notifyListeners();
  }

  void toggleTaskSelection(int index) {
    if (_selectedTasks.contains(index)) {
      _selectedTasks.remove(index);
    } else {
      _selectedTasks.add(index);
    }
    notifyListeners();
  }

  void selectAllTasks() {
    _selectedTasks = Set.from(List.generate(_tasks.length, (index) => index));
    notifyListeners();
  }

  void clearSelection() {
    _selectedTasks.clear();
    notifyListeners();
  }

  Future<void> bulkDeleteSelected() async {
    final selectedIndices = _selectedTasks.toList()..sort((a, b) => b.compareTo(a));
    for (final index in selectedIndices) {
      await deleteTask(index);
    }
    _selectedTasks.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  Future<void> bulkMarkCompleted() async {
    final selectedIndices = _selectedTasks.toList();
    for (final index in selectedIndices) {
      final task = _tasks[index];
      if (!task.isDone) {
        task.isDone = true;
        await updateTask(index, task);
      }
    }
    _selectedTasks.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  Future<void> bulkChangeCategory(TaskCategory category) async {
    final selectedIndices = _selectedTasks.toList();
    for (final index in selectedIndices) {
      final task = _tasks[index];
      task.category = category;
      await updateTask(index, task);
    }
    _selectedTasks.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  Future<void> bulkChangePriority(TaskPriority priority) async {
    final selectedIndices = _selectedTasks.toList();
    for (final index in selectedIndices) {
      final task = _tasks[index];
      task.priority = priority;
      await updateTask(index, task);
    }
    _selectedTasks.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  String exportToJson() {
    final exportData = _tasks.map((task) => task.toJson()).toList();
    return jsonEncode(exportData);
  }

  String exportToCsv() {
    final buffer = StringBuffer();
    buffer.writeln('Title,Description,Priority,Category,Due Date,Created Date,Completed,Recurring');

    for (final task in _tasks) {
      final row = [
        task.title,
        task.notes ?? '',
        task.priority.name,
        task.category.name,
        task.dueDate?.toIso8601String() ?? '',
        task.createdAt.toIso8601String(),
        task.isDone.toString(),
        task.isRecurring.toString(),
      ];
      buffer.writeln(row.map((field) => '"${field.replaceAll('"', '""')}"').join(','));
    }

    return buffer.toString();
  }

  // Statistics and insights
  Map<String, dynamic> getStatistics() {
    final total = _tasks.length;
    final completed = _tasks.where((t) => t.isDone).length;
    final pending = total - completed;
    final overdue = _tasks.where((t) => t.isOverdue).length;

    final categoryStats = <TaskCategory, int>{};
    for (final category in TaskCategory.values) {
      categoryStats[category] = _tasks.where((t) => t.category == category).length;
    }

    final priorityStats = <TaskPriority, int>{};
    for (final priority in TaskPriority.values) {
      priorityStats[priority] = _tasks.where((t) => t.priority == priority).length;
    }

    final completionRate = total > 0 ? (completed / total) * 100 : 0.0;

    // Calculate streaks and patterns
    final completedTasks = _tasks.where((t) => t.isDone).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int currentStreak = 0;
    int longestStreak = 0;
    DateTime? lastCompletionDate;

    for (final task in completedTasks) {
      final taskDate = task.createdAt;
      if (lastCompletionDate == null ||
          taskDate.difference(lastCompletionDate).inDays <= 1) {
        currentStreak++;
      } else {
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
        currentStreak = 1;
      }
      lastCompletionDate = taskDate;
    }
    longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
      'completionRate': completionRate,
      'categoryStats': categoryStats,
      'priorityStats': priorityStats,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
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