import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/todolist.dart';

void main() {
  runApp(const appRun());
}

class appRun extends StatelessWidget {
  const appRun({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "dhkekek",
      home: helloo(),
    );
  }
}

class helloo extends StatelessWidget {
  const helloo({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
      ),
      body: FutureBuilder(
        future: todoProvider.fetchTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          return ListView.builder(
              itemCount: todoProvider.todos.length,
              itemBuilder: (context, index) {
                final todo = todoProvider.todos[index];
                return ListTile(
                  title: Text(todo.title),
                  trailing: Checkbox(
                      value: todo.completed,
                      onChanged: (value) {
                        todoProvider.toogleComplete(todo);
                      }),
                );
              });
        },
      ),
    );
  }
}
