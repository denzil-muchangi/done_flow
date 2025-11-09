import 'package:done_flow/core/models/tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  Color _getPriorityColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (task.priority) {
      case TaskPriority.high:
        return isDark ? Colors.red.shade300 : Colors.red.shade600;
      case TaskPriority.medium:
        return isDark ? Colors.orange.shade300 : Colors.orange.shade600;
      case TaskPriority.low:
        return isDark ? Colors.green.shade300 : Colors.green.shade600;
    }
  }

  Color _getCategoryColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (task.category) {
      case TaskCategory.work:
        return isDark ? Colors.blue.shade300 : Colors.blue.shade600;
      case TaskCategory.personal:
        return isDark ? Colors.purple.shade300 : Colors.purple.shade600;
      case TaskCategory.shopping:
        return isDark ? Colors.teal.shade300 : Colors.teal.shade600;
      case TaskCategory.health:
        return isDark ? Colors.pink.shade300 : Colors.pink.shade600;
      case TaskCategory.other:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    }
  }

  IconData _getCategoryIcon() {
    switch (task.category) {
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

  String _getPriorityText() {
    switch (task.priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key(task.title + task.createdAt.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Card(
        elevation: task.isOverdue ? 8 : 2,
        shadowColor: task.isOverdue ? Colors.red.withOpacity(0.3) : null,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Selection checkbox (when in selection mode)
                    if (isSelectionMode) ...[
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => onSelectionChanged?.call(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Priority indicator
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(context),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ).animate(
                      target: task.isOverdue ? 1 : 0,
                    ).shake(duration: 500.ms),
                    const SizedBox(width: 12),

                    // Checkbox with animation (only when not in selection mode)
                    if (!isSelectionMode)
                      Checkbox(
                        value: task.isDone,
                        onChanged: (_) => onToggle(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).animate(
                        target: task.isDone ? 1 : 0,
                      ).scale(duration: 200.ms),

                    const SizedBox(width: 12),

                    // Task content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: task.isDone ? TextDecoration.lineThrough : null,
                              color: task.isDone
                                  ? colorScheme.onSurface.withOpacity(0.6)
                                  : colorScheme.onSurface,
                              fontWeight: task.isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (task.notes != null && task.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.notes!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Category icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        size: 20,
                        color: _getCategoryColor(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Bottom row with metadata
                Row(
                  children: [
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getPriorityText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getPriorityColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Due date
                    if (task.dueDate != null) ...[
                      Icon(
                        task.isOverdue ? Icons.warning : Icons.calendar_today,
                        size: 16,
                        color: task.isOverdue
                            ? Colors.red
                            : colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d').format(task.dueDate!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: task.isOverdue
                              ? Colors.red
                              : colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: task.isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (task.isRecurring) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.repeat,
                          size: 14,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ],
                    ],

                    const Spacer(),

                    // Created date
                    Text(
                      DateFormat('MMM d, yyyy').format(task.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms),
    );
  }
}