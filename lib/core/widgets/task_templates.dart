import 'package:done_flow/core/models/tasks.dart';
import 'package:flutter/material.dart';

class TaskTemplate {
  final String name;
  final String title;
  final TaskPriority priority;
  final TaskCategory category;
  final String? notes;
  final RecurrenceType recurrence;

  const TaskTemplate({
    required this.name,
    required this.title,
    required this.priority,
    required this.category,
    this.notes,
    this.recurrence = RecurrenceType.none,
  });
}

class TaskTemplates {
  static const List<TaskTemplate> templates = [
    TaskTemplate(
      name: 'Morning Workout',
      title: 'Morning workout session',
      priority: TaskPriority.high,
      category: TaskCategory.health,
      notes: '30-minute cardio and strength training',
      recurrence: RecurrenceType.daily,
    ),
    TaskTemplate(
      name: 'Team Meeting',
      title: 'Weekly team sync',
      priority: TaskPriority.high,
      category: TaskCategory.work,
      notes: 'Discuss progress and blockers',
      recurrence: RecurrenceType.weekly,
    ),
    TaskTemplate(
      name: 'Grocery Shopping',
      title: 'Weekly grocery shopping',
      priority: TaskPriority.medium,
      category: TaskCategory.shopping,
      notes: 'Plan meals and make shopping list',
      recurrence: RecurrenceType.weekly,
    ),
    TaskTemplate(
      name: 'Doctor Appointment',
      title: 'Regular health checkup',
      priority: TaskPriority.high,
      category: TaskCategory.health,
      notes: 'Annual physical examination',
      recurrence: RecurrenceType.yearly,
    ),
    TaskTemplate(
      name: 'Project Review',
      title: 'Monthly project review',
      priority: TaskPriority.medium,
      category: TaskCategory.work,
      notes: 'Review progress and adjust goals',
      recurrence: RecurrenceType.monthly,
    ),
    TaskTemplate(
      name: 'Family Dinner',
      title: 'Family dinner night',
      priority: TaskPriority.medium,
      category: TaskCategory.personal,
      notes: 'Cook and enjoy meal together',
      recurrence: RecurrenceType.weekly,
    ),
    TaskTemplate(
      name: 'Bill Payment',
      title: 'Monthly bill payments',
      priority: TaskPriority.high,
      category: TaskCategory.other,
      notes: 'Pay utilities, rent, and subscriptions',
      recurrence: RecurrenceType.monthly,
    ),
    TaskTemplate(
      name: 'Reading Time',
      title: 'Daily reading session',
      priority: TaskPriority.low,
      category: TaskCategory.personal,
      notes: 'Read for personal development',
      recurrence: RecurrenceType.daily,
    ),
  ];

  static Task createTaskFromTemplate(TaskTemplate template, {DateTime? dueDate}) {
    return Task(
      title: template.title,
      priority: template.priority,
      category: template.category,
      dueDate: dueDate,
      notes: template.notes,
      recurrence: template.recurrence,
      recurrenceInterval: 1,
    );
  }
}

class TaskTemplateSelector extends StatelessWidget {
  final Function(Task) onTemplateSelected;

  const TaskTemplateSelector({super.key, required this.onTemplateSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Templates',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a template to get started quickly',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: TaskTemplates.templates.length,
                itemBuilder: (context, index) {
                  final template = TaskTemplates.templates[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        final task = TaskTemplates.createTaskFromTemplate(template);
                        onTemplateSelected(task);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(template.category).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getCategoryIcon(template.category),
                                color: _getCategoryColor(template.category),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    template.title,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  if (template.recurrence != RecurrenceType.none) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.repeat,
                                          size: 14,
                                          color: colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Repeats ${template.recurrence.name}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurface.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.purple;
      case TaskCategory.shopping:
        return Colors.teal;
      case TaskCategory.health:
        return Colors.pink;
      case TaskCategory.other:
        return Colors.grey;
    }
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
}