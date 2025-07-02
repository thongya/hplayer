import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'task_database.dart';

void main() {
  runApp(const MyAppam());
}

class MyAppam extends StatelessWidget {
  const MyAppam({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter User CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const UserListPage1(),
    );
  }
}

class UserListPage1 extends StatefulWidget {
  const UserListPage1({super.key});

  @override
  State<UserListPage1> createState() => _UserListPage1State();
}

class _UserListPage1State extends State<UserListPage1> {

  List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  bool _showActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TaskDatabase.instance.insert({'task': 'Test Task', 'completed': 0});
      await _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    final data = await TaskDatabase.instance.getAllTasks();
    setState(() => _tasks = data);
  }

  Future<void> _updateTask(int index, String updatedTask) async {
    final int id = _tasks[index]['id']; // Get the ID of the selected task

    await TaskDatabase.instance.update(id, {
      'task': updatedTask,
      'completed': _tasks[index]['completed'] == 1, // Keep current completed status
    });

    await _loadTasks(); // Refresh the task list
  }

  Future<void> _addTask(String task) async {
    await TaskDatabase.instance.insert({
      'task': task,
      'completed': 0,
    });
    await _loadTasks();
  }


  void _showTaskDialog({int? index}) {
    TextEditingController _taskController = TextEditingController(
      text: index != null ? _tasks[index]['task'] : '',
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(index == null ? 'add task' : 'edit task'),
            content: TextField(
              controller: _taskController,
              decoration: InputDecoration(hintText: 'Enter task'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async {
                  final text = _taskController.text.trim();
                  if (text.isNotEmpty) {
                    if (index == null) {
                      await _addTask(text);
                    } else {
                      await _updateTask(index, text);
                    }
                    Navigator.pop(context);
                  }
                },

                // onPressed: () {
                //   if (_taskController.text.trim().isNotEmpty) {
                //     setState(() {
                //       if (index == null) {
                //         _tasks.add({
                //           'task': _taskController.text.trim(),
                //           'completed': false,
                //         });
                //       } else {
                //         _tasks[index]['task'] = _taskController.text.trim();
                //       }
                //     });
                //     Navigator.pop(context);
                //   }
                // },
                child: Text("Save"),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteTask(int index) async {
    final id = _tasks[index]['id'];
    await TaskDatabase.instance.delete(id);
    await _loadTasks();
  }


  int get activeCount => _tasks.where((task) => !task['completed']).length;

  int get completedCount => _tasks.where((task) => task['completed']).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(title: Text("Todo app")),
      body: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(activeCount.toString()),
                        Text('Active', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(completedCount.toString()),
                        Text('Completed', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_tasks[index]['task']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _tasks[index]['completed'] == 1,
                            onChanged: (value) async {
                              final id = _tasks[index]['id'];
                              await TaskDatabase.instance.update(id, {
                                'task': _tasks[index]['task'],
                                'completed': value! ? 1 : 0,
                              });
                              await _loadTasks();
                            }

                        ),
                      ],
                    ),

                    onTap: () => _showTaskDialog(index: index),
                  ),
                );
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTask(index),
                );
                // return Container(
                //   color: Colors.green,
                //   child: Icon(Icons.check, color: Colors.red,),
                // );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
