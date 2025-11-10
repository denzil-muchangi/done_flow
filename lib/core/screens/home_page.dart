import 'package:done_flow/core/models/tasks.dart';
import 'package:done_flow/core/providers/task_provider.dart';
import 'package:done_flow/core/providers/theme_provider.dart';
import 'package:done_flow/core/widgets/add_task_dialog.dart';
import 'package:done_flow/core/widgets/archive_screen.dart';
import 'package:done_flow/core/widgets/bulk_actions_bar.dart';
import 'package:done_flow/core/widgets/filter_bar.dart';
import 'package:done_flow/core/widgets/settings_screen.dart';
import 'package:done_flow/core/widgets/task_templates.dart';
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

  void _showTemplateSelector() {
    showDialog(
      context: context,
      builder: (context) => TaskTemplateSelector(
        onTemplateSelected: (task) {
          context.read<TaskProvider>().addTask(task);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template "${task.title}" added successfully!'),
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
          const BulkActionsBar(),
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
                                  taskProvider.selectedPriority != null ||
                                  taskProvider.dateRangeFilter != null
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
                      isSelectionMode: taskProvider.isSelectionMode,
                      isSelected: taskProvider.selectedTasks.contains(originalIndex),
                      onSelectionChanged: () => taskProvider.toggleTaskSelection(originalIndex),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add new task',
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ).animate(
        controller: _fabAnimationController,
      ).scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 200.ms,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: _showTemplateSelector,
              tooltip: 'Use template',
            ),
            const SizedBox(width: 48), // Space for FAB
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreOptionsMenu(context),
              tooltip: 'More options',
            ),
          ],
        ),
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

  void _showMoreOptionsMenu(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.select_all),
            title: const Text('Select Tasks'),
            subtitle: const Text('Choose multiple tasks for bulk actions'),
            onTap: () {
              Navigator.of(context).pop();
              taskProvider.toggleSelectionMode();
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archive View'),
            subtitle: const Text('View completed tasks'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ArchiveScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            subtitle: const Text('App preferences and settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
