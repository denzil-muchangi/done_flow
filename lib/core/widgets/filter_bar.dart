import 'package:done_flow/core/models/tasks.dart';
import 'package:done_flow/core/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              // Search bar
              TextField(
                onChanged: taskProvider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: taskProvider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => taskProvider.setSearchQuery(''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Show completed toggle
                    FilterChip(
                      label: Text(taskProvider.showCompleted ? 'Hide Completed' : 'Show Completed'),
                      selected: !taskProvider.showCompleted,
                      onSelected: (_) => taskProvider.toggleShowCompleted(),
                      avatar: Icon(
                        taskProvider.showCompleted ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Clear filters
                    if (taskProvider.searchQuery.isNotEmpty ||
                        taskProvider.selectedCategory != null ||
                        taskProvider.selectedPriority != null ||
                        !taskProvider.showCompleted)
                      ActionChip(
                        label: const Text('Clear Filters'),
                        onPressed: taskProvider.clearFilters,
                        avatar: const Icon(Icons.clear_all),
                      ),

                    const SizedBox(width: 8),

                    // Category filters
                    ...TaskCategory.values.map((category) {
                      final count = taskProvider.categoryCounts[category] ?? 0;
                      final isSelected = taskProvider.selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${category.name} ($count)'),
                          selected: isSelected,
                          onSelected: (selected) {
                            taskProvider.setCategoryFilter(selected ? category : null);
                          },
                          avatar: Icon(
                            category == TaskCategory.work
                                ? Icons.work
                                : category == TaskCategory.personal
                                    ? Icons.person
                                    : category == TaskCategory.shopping
                                        ? Icons.shopping_cart
                                        : category == TaskCategory.health
                                            ? Icons.health_and_safety
                                            : Icons.category,
                            size: 18,
                          ),
                        ),
                      );
                    }),

                    // Priority filters
                    ...TaskPriority.values.map((priority) {
                      final count = taskProvider.priorityCounts[priority] ?? 0;
                      final isSelected = taskProvider.selectedPriority == priority;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${priority.name} ($count)'),
                          selected: isSelected,
                          onSelected: (selected) {
                            taskProvider.setPriorityFilter(selected ? priority : null);
                          },
                          avatar: Icon(
                            priority == TaskPriority.high
                                ? Icons.priority_high
                                : priority == TaskPriority.medium
                                    ? Icons.remove
                                    : Icons.low_priority,
                            size: 18,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatChip(
                      label: 'Total',
                      value: taskProvider.tasks.length,
                      icon: Icons.list,
                      color: colorScheme.primary,
                    ),
                    _StatChip(
                      label: 'Pending',
                      value: taskProvider.pendingTasksCount,
                      icon: Icons.pending,
                      color: colorScheme.secondary,
                    ),
                    _StatChip(
                      label: 'Completed',
                      value: taskProvider.completedTasksCount,
                      icon: Icons.check_circle,
                      color: colorScheme.tertiary,
                    ),
                    if (taskProvider.overdueTasksCount > 0)
                      _StatChip(
                        label: 'Overdue',
                        value: taskProvider.overdueTasksCount,
                        icon: Icons.warning,
                        color: Colors.red,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}