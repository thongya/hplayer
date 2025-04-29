import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptt/model/todo.dart';
import 'dart:convert';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  // List<Todo> get doneTodos => _todos.where((todo) => todo.done == true).toList();
  Future<void> fetchTodos() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _todos = data.map((item) => Todo.fromJson(item)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  void toogleComplete(Todo todo) {
    final index = _todos.indexOf(todo);
    _todos[index] =
        Todo(id: todo.id, title: todo.title, completed: !todo.completed);
    notifyListeners();
  }
}
