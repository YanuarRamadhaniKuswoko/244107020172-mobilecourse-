import 'package:flutter/material.dart';
import 'package:testing_lab/is_valid_task_title.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TaskPage(),
    );
  }
}

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _tasks = [];
  String? _errorMessage;

  void _saveTask() {
    final text = _controller.text;
    if (isValidTaskTitle(text)) {
      setState(() {
        _tasks.add(text.trim());
        _controller.clear();
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = 'Judul tugas tidak boleh kosong';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar tugas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              key: const Key('task-title-field'),
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Judul tugas',
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              key: const Key('save-task-button'),
              onPressed: _saveTask,
              child: const Text('Simpan'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_tasks[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
