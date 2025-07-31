import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../model/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);

  UnmodifiableListView<Task> get completedTasks =>
      UnmodifiableListView(_tasks.where((task) => task.isCompleted).toList());

  UnmodifiableListView<Task> get pendingTasks =>
      UnmodifiableListView(_tasks.where((task) => !task.isCompleted).toList());

  void addTask(String title, String? description, DateTime? dueDate) {
    final newTask = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
    _tasks.add(newTask);
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final task = _tasks.firstWhere((task) => task.id == id);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    final index = _tasks.indexOf(task);
    _tasks[index] = updatedTask;
    notifyListeners();
  }

  void updateTask(String id, String title, String? description, DateTime? dueDate) {
    final task = _tasks.firstWhere((task) => task.id == id);
    final updatedTask = task.copyWith(
      title: title,
      description: description,
      dueDate: dueDate,
    );
    final index = _tasks.indexOf(task);
    _tasks[index] = updatedTask;
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}