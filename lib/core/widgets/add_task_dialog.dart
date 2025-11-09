import 'package:done_flow/core/models/tasks.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onAdd;

  const AddTaskDialog({super.key, required this.onAdd});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.other;
  DateTime? _dueDate;
  RecurrenceType _recurrence = RecurrenceType.none;
  int _recurrenceInterval = 1;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      title: _titleController.text.trim(),
      priority: _priority,
      category: _category,
      dueDate: _dueDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      recurrence: _recurrence,
      recurrenceInterval: _recurrenceInterval,
    );

    widget.onAdd(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Task',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Title field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Notes field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add additional details...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.notes),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Priority selector
            Text(
              'Priority',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TaskPriority>(
              segments: TaskPriority.values.map((priority) {
                return ButtonSegment<TaskPriority>(
                  value: priority,
                  label: Text(priority.name.toUpperCase()),
                  icon: Icon(
                    priority == TaskPriority.high
                        ? Icons.priority_high
                        : priority == TaskPriority.medium
                            ? Icons.remove
                            : Icons.low_priority,
                  ),
                );
              }).toList(),
              selected: {_priority},
              onSelectionChanged: (selected) {
                setState(() => _priority = selected.first);
              },
            ),
            const SizedBox(height: 20),

            // Category selector
            Text(
              'Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategory.values.map((category) {
                final isSelected = _category == category;
                return FilterChip(
                  label: Text(category.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _category = category);
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
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Due date picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate != null
                        ? 'Due: ${DateFormat('MMM d, yyyy').format(_dueDate!)}'
                        : 'No due date',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _selectDueDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_dueDate != null ? 'Change' : 'Set Date'),
                ),
                if (_dueDate != null)
                  IconButton(
                    onPressed: () => setState(() => _dueDate = null),
                    icon: const Icon(Icons.clear),
                    tooltip: 'Remove due date',
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Recurrence selector
            Text(
              'Repeat',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<RecurrenceType>(
              value: _recurrence,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: RecurrenceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type == RecurrenceType.none
                        ? 'Never'
                        : type.name.toUpperCase(),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _recurrence = value!),
            ),
            if (_recurrence != RecurrenceType.none) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Every', style: theme.textTheme.bodyMedium),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      controller: TextEditingController(text: _recurrenceInterval.toString()),
                      onChanged: (value) {
                        final interval = int.tryParse(value);
                        if (interval != null && interval > 0) {
                          setState(() => _recurrenceInterval = interval);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _recurrence == RecurrenceType.daily
                        ? 'day(s)'
                        : _recurrence == RecurrenceType.weekly
                            ? 'week(s)'
                            : _recurrence == RecurrenceType.monthly
                                ? 'month(s)'
                                : 'year(s)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _titleController.text.trim().isEmpty ? null : _submit,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}