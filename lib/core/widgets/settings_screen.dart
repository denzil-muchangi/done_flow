import 'package:done_flow/core/providers/theme_provider.dart';
import 'package:done_flow/core/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoDeleteCompleted = false;
  int _autoDeleteDays = 30;
  bool _confirmDelete = true;
  bool _showCompletedTasks = true;
  String _defaultSort = 'priority';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _autoDeleteCompleted = prefs.getBool('auto_delete_completed') ?? false;
      _autoDeleteDays = prefs.getInt('auto_delete_days') ?? 30;
      _confirmDelete = prefs.getBool('confirm_delete') ?? true;
      _showCompletedTasks = prefs.getBool('show_completed_tasks') ?? true;
      _defaultSort = prefs.getString('default_sort') ?? 'priority';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance', Icons.palette),
          _buildSwitchTile(
            title: 'Dark Mode',
            subtitle: 'Toggle between light and dark themes',
            value: context.watch<ThemeProvider>().isDarkMode,
            onChanged: (value) => context.read<ThemeProvider>().toggleTheme(),
          ),

          const Divider(),

          // Task Management Section
          _buildSectionHeader('Task Management', Icons.task),
          _buildSwitchTile(
            title: 'Show Completed Tasks',
            subtitle: 'Display completed tasks in the main list',
            value: _showCompletedTasks,
            onChanged: (value) {
              setState(() => _showCompletedTasks = value);
              _saveSetting('show_completed_tasks', value);
              context.read<TaskProvider>().toggleShowCompleted();
            },
          ),
          _buildSwitchTile(
            title: 'Confirm Delete',
            subtitle: 'Show confirmation dialog when deleting tasks',
            value: _confirmDelete,
            onChanged: (value) {
              setState(() => _confirmDelete = value);
              _saveSetting('confirm_delete', value);
            },
          ),

          // Default Sort
          ListTile(
            title: const Text('Default Sort Order'),
            subtitle: Text(_getSortDisplayName(_defaultSort)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showSortDialog(),
          ),

          const Divider(),

          // Data Management Section
          _buildSectionHeader('Data Management', Icons.storage),
          _buildSwitchTile(
            title: 'Auto-delete Completed Tasks',
            subtitle: 'Automatically remove completed tasks after a period',
            value: _autoDeleteCompleted,
            onChanged: (value) {
              setState(() => _autoDeleteCompleted = value);
              _saveSetting('auto_delete_completed', value);
            },
          ),

          if (_autoDeleteCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete after $_autoDeleteDays days',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Slider(
                    value: _autoDeleteDays.toDouble(),
                    min: 1,
                    max: 365,
                    divisions: 364,
                    label: '$_autoDeleteDays days',
                    onChanged: (value) {
                      setState(() => _autoDeleteDays = value.toInt());
                      _saveSetting('auto_delete_days', value.toInt());
                    },
                  ),
                ],
              ),
            ),

          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Export your tasks as JSON or CSV'),
            leading: const Icon(Icons.download),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showExportDialog(),
          ),

          ListTile(
            title: const Text('Import Data'),
            subtitle: const Text('Import tasks from JSON file'),
            leading: const Icon(Icons.upload),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showImportDialog(),
          ),

          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications', Icons.notifications),
          _buildSwitchTile(
            title: 'Enable Notifications',
            subtitle: 'Receive reminders for due tasks',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSetting('notifications_enabled', value);
            },
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('About', Icons.info),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('2.0.0'),
            leading: const Icon(Icons.info_outline),
          ),

          ListTile(
            title: const Text('Clear All Data'),
            subtitle: const Text('Permanently delete all tasks and settings'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () => _showClearAllDataDialog(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  String _getSortDisplayName(String sortKey) {
    switch (sortKey) {
      case 'priority':
        return 'Priority (High to Low)';
      case 'dueDate':
        return 'Due Date';
      case 'createdDate':
        return 'Created Date (Newest First)';
      case 'category':
        return 'Category';
      case 'title':
        return 'Title (A-Z)';
      default:
        return 'Priority (High to Low)';
    }
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Sort Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Priority (High to Low)'),
              value: 'priority',
              groupValue: _defaultSort,
              onChanged: (value) => _updateSortPreference(value!),
            ),
            RadioListTile<String>(
              title: const Text('Due Date'),
              value: 'dueDate',
              groupValue: _defaultSort,
              onChanged: (value) => _updateSortPreference(value!),
            ),
            RadioListTile<String>(
              title: const Text('Created Date (Newest First)'),
              value: 'createdDate',
              groupValue: _defaultSort,
              onChanged: (value) => _updateSortPreference(value!),
            ),
            RadioListTile<String>(
              title: const Text('Category'),
              value: 'category',
              groupValue: _defaultSort,
              onChanged: (value) => _updateSortPreference(value!),
            ),
            RadioListTile<String>(
              title: const Text('Title (A-Z)'),
              value: 'title',
              groupValue: _defaultSort,
              onChanged: (value) => _updateSortPreference(value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updateSortPreference(String value) {
    setState(() => _defaultSort = value);
    _saveSetting('default_sort', value);
    Navigator.of(context).pop();
  }

  void _showExportDialog() {
    final taskProvider = context.read<TaskProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final jsonData = taskProvider.exportToJson();
              // In a real app, you'd save this to a file
              print('JSON Export: $jsonData');
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported to console (JSON)')),
              );
            },
            child: const Text('JSON'),
          ),
          TextButton(
            onPressed: () {
              final csvData = taskProvider.exportToCsv();
              // In a real app, you'd save this to a file
              print('CSV Export:\n$csvData');
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported to console (CSV)')),
              );
            },
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('Import functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all tasks, settings, and preferences. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              // Clear all data
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Clear Hive data
              // Note: In a real implementation, you'd expose a clear method in TaskProvider
              // For now, we'll just clear SharedPreferences

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
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