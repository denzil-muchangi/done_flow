import 'package:done_flow/core/models/tasks.dart';
import 'package:done_flow/core/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BulkActionsBar extends StatelessWidget {
  const BulkActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (!taskProvider.isSelectionMode || taskProvider.selectedTasks.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedCount = taskProvider.selectedTasks.length;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            border: Border(
              top: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                '$selectedCount selected',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _showBulkCompleteDialog(context),
                tooltip: 'Mark as completed',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showBulkDeleteDialog(context),
                tooltip: 'Delete selected',
              ),
              IconButton(
                icon: const Icon(Icons.category),
                onPressed: () => _showBulkCategoryDialog(context),
                tooltip: 'Change category',
              ),
              IconButton(
                icon: const Icon(Icons.priority_high),
                onPressed: () => _showBulkPriorityDialog(context),
                tooltip: 'Change priority',
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: taskProvider.clearSelection,
                tooltip: 'Clear selection',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBulkCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: const Text('Mark all selected tasks as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskProvider>().bulkMarkCompleted();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tasks marked as completed')),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tasks'),
        content: const Text('Are you sure you want to delete all selected tasks? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              context.read<TaskProvider>().bulkDeleteSelected();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tasks deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBulkCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskCategory.values.map((category) {
            return ListTile(
              title: Text(category.name.toUpperCase()),
              leading: Icon(_getCategoryIcon(category)),
              onTap: () {
                context.read<TaskProvider>().bulkChangeCategory(category);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category changed to ${category.name}')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBulkPriorityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskPriority.values.map((priority) {
            return ListTile(
              title: Text(priority.name.toUpperCase()),
              leading: Icon(_getPriorityIcon(priority)),
              onTap: () {
                context.read<TaskProvider>().bulkChangePriority(priority);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Priority changed to ${priority.name}')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.shopping:
        return Icons.shopping_cart;
      case TaskCategory.health:
        return Icons.health_and_safety;
      case TaskCategory.other:
        return Icons.category;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.low_priority;
    }
  }
}