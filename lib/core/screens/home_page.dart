import 'package:done_flow/core/models/tasks.dart';
import 'package:done_flow/core/providers/task_provider.dart';
import 'package:done_flow/core/providers/theme_provider.dart';
import 'package:done_flow/core/widgets/add_task_dialog.dart';
import 'package:done_flow/core/widgets/filter_bar.dart';
import 'package:done_flow/core/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onAdd: (task) {
          context.read<TaskProvider>().addTask(task);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${task.title}" added successfully!'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // TODO: Implement undo functionality
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
            tooltip: 'Toggle theme',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear_completed':
                  _showClearCompletedDialog();
                  break;
                case 'clear_all':
                  _showClearAllDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_completed',
                child: Text('Clear completed tasks'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear all tasks'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const FilterBar(),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                final tasks = taskProvider.tasks;

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 80,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          taskProvider.searchQuery.isNotEmpty ||
                                  taskProvider.selectedCategory != null ||
                                  taskProvider.selectedPriority != null
                              ? 'No tasks match your filters'
                              : 'No tasks yet!\nTap + to add one',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final originalIndex = taskProvider.allTasks.indexOf(task);

                    return TaskTile(
                      task: task,
                      onToggle: () => taskProvider.toggleTask(originalIndex),
                      onDelete: () => _deleteTask(originalIndex, task),
                      onEdit: () => _editTask(originalIndex, task),
                    ).animate(
                      delay: (index * 50).ms,
                    ).fadeIn(duration: 300.ms).slideX(begin: 0.2);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add new task',
        child: const Icon(Icons.add),
      ).animate(
        controller: _fabAnimationController,
      ).scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 200.ms,
      ),
    );
  }

  void _deleteTask(int index, Task task) {
    context.read<TaskProvider>().deleteTask(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }

  void _editTask(int index, Task task) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  void _showClearCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: const Text('Are you sure you want to delete all completed tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement clear completed functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Completed tasks cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Tasks'),
        content: const Text('Are you sure you want to delete all tasks? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              // TODO: Implement clear all functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All tasks cleared')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
