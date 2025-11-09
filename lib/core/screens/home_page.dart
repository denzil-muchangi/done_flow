import 'dart:convert';

import 'package:done_flow/core/models/tasks.dart';
import 'package:done_flow/core/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> tasks =[];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  _loadTask() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        tasks = (jsonDecode(tasksJson) as List)
            .map((e) => Task.fromJson(e))
            .toList();
      });
    }
  }

  _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(tasks.map((e) => e.toJson()).toList());
    prefs.setString('tasks', tasksJson);
  }

  void _addTask() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      tasks.add(Task(title: _controller.text.trim()));
      _controller.clear();
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              // Toggle theme later
            },
          )
        ],
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet!\nTap + to add one',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (ctx, i) {
                return TaskTile(
                  task: tasks[i],
                  onToggle: () {
                    setState(() {
                      tasks[i].isDone = !tasks[i].isDone;
                      _saveTasks();
                    });
                  },
                  onDelete: () {
                    setState(() {
                      tasks.removeAt(i);
                      _saveTasks();
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('New Task'),
              content: TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Enter task'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _addTask();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
