import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/task.dart';
import '../provider/task_provider.dart';
import '../widgets/task_item.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addTask(String title, String? description, DateTime? dueDate) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.addTask(title, description, dueDate);
  }

  void _editTask(String id, String title, String? description, DateTime? dueDate) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.updateTask(id, title, description, dueDate);
  }

  void _deleteTask(String id) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.deleteTask(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleTask(String id) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.toggleTaskStatus(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          List<Task> tasksToShow = [];
          switch (_selectedIndex) {
            case 0:
              tasksToShow = taskProvider.tasks.toList();
              break;
            case 1:
              tasksToShow = taskProvider.pendingTasks.toList();
              break;
            case 2:
              tasksToShow = taskProvider.completedTasks.toList();
              break;
          }

          if (tasksToShow.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedIndex == 1
                        ? Icons.pending_actions
                        : _selectedIndex == 2
                        ? Icons.check_circle_outline
                        : Icons.task_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedIndex == 1
                        ? 'No pending tasks'
                        : _selectedIndex == 2
                        ? 'No completed tasks'
                        : 'No tasks yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tasksToShow.length,
            itemBuilder: (context, index) {
              final task = tasksToShow[index];
              return TaskItem(
                task: task,
                onToggle: () => _toggleTask(task.id),
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTaskScreen(
                        task: task,
                        onTaskUpdated: (title, description, dueDate) {
                          _editTask(task.id, title, description, dueDate);
                        },
                      ),
                    ),
                  );
                },
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Task'),
                      content: const Text('Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteTask(task.id);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(
                onTaskAdded: _addTask,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}