import 'package:done_flow/core/models/tasks.dart';
import 'package:done_flow/core/providers/task_provider.dart';
import 'package:done_flow/core/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  String _searchQuery = '';
  TaskCategory? _selectedCategory;
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter archive',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search archived tasks...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  ),
                ),
                if (_selectedCategory != null || _dateRange != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (_selectedCategory != null)
                        Chip(
                          label: Text('Category: ${_selectedCategory!.name}'),
                          onDeleted: () => setState(() => _selectedCategory = null),
                        ),
                      if (_dateRange != null)
                        Chip(
                          label: Text('Date: ${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'),
                          onDeleted: () => setState(() => _dateRange = null),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Archive content
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final archivedTasks = taskProvider.allTasks
                    .where((task) => task.isDone)
                    .where((task) {
                      // Search filter
                      if (_searchQuery.isNotEmpty) {
                        final query = _searchQuery.toLowerCase();
                        return task.title.toLowerCase().contains(query) ||
                               (task.notes?.toLowerCase().contains(query) ?? false);
                      }
                      return true;
                    })
                    .where((task) => _selectedCategory == null || task.category == _selectedCategory)
                    .where((task) {
                      if (_dateRange != null && task.createdAt != null) {
                        return task.createdAt.isAfter(_dateRange!.start) &&
                               task.createdAt.isBefore(_dateRange!.end.add(const Duration(days: 1)));
                      }
                      return true;
                    })
                    .toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (archivedTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.archive_outlined,
                          size: 80,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No archived tasks',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Completed tasks will appear here',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: archivedTasks.length,
                  itemBuilder: (context, index) {
                    final task = archivedTasks[index];
                    final originalIndex = taskProvider.allTasks.indexOf(task);

                    return TaskTile(
                      task: task,
                      onToggle: () => taskProvider.toggleTask(originalIndex),
                      onDelete: () => _restoreTask(context, originalIndex, task),
                      onEdit: () => _showTaskDetails(context, task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBulkRestoreDialog(context),
        icon: const Icon(Icons.restore),
        label: const Text('Restore All'),
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.onTertiary,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Archive'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category filter
            DropdownButtonFormField<TaskCategory?>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...TaskCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name.toUpperCase()),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 16),

            // Date range picker
            ListTile(
              title: const Text('Date Range'),
              subtitle: _dateRange != null
                  ? Text('${DateFormat('MMM d, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_dateRange!.end)}')
                  : const Text('Select date range'),
              trailing: const Icon(Icons.date_range),
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                );
                if (range != null) {
                  setState(() => _dateRange = range);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _dateRange = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear Filters'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _restoreTask(BuildContext context, int index, Task task) {
    context.read<TaskProvider>().toggleTask(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task.title}" restored'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => context.read<TaskProvider>().toggleTask(index),
        ),
      ),
    );
  }

  void _showBulkRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore All Tasks'),
        content: const Text('Move all archived tasks back to active tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final taskProvider = context.read<TaskProvider>();
              final archivedTasks = taskProvider.allTasks
                  .where((task) => task.isDone)
                  .toList();

              for (final task in archivedTasks) {
                final index = taskProvider.allTasks.indexOf(task);
                taskProvider.toggleTask(index);
              }

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${archivedTasks.length} tasks restored'),
                ),
              );
            },
            child: const Text('Restore All'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.notes != null && task.notes!.isNotEmpty) ...[
              Text('Notes:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(task.notes!),
              const SizedBox(height: 16),
            ],
            Text('Category: ${task.category.name.toUpperCase()}'),
            Text('Priority: ${task.priority.name.toUpperCase()}'),
            if (task.dueDate != null)
              Text('Due: ${DateFormat('MMM d, yyyy').format(task.dueDate!)}'),
            Text('Completed: ${DateFormat('MMM d, yyyy').format(task.createdAt)}'),
            if (task.isRecurring)
              Text('Recurring: ${task.recurrence.name} (every ${task.recurrenceInterval} ${task.recurrence.name}${task.recurrenceInterval! > 1 ? 's' : ''})'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}