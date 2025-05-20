import 'package:flutter/material.dart';

void main(){
  runApp(app());
}
class app extends StatelessWidget {
  const app({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: myscreen(),
    );
  }
}
class myscreen extends StatefulWidget {
  const myscreen({super.key});

  @override
  _myscreenState createState() => _myscreenState();
}


final List<String> _tasks = [];
final TextEditingController _controller = TextEditingController();

void _addTask() {
  if (_controller.text.isNotEmpty) {
    setState(() {
      _tasks.add(_controller.text);
      _controller.clear();
    });
  }
}

void setState(Null Function() param0) {
}

void _removeTask(int index) {
  setState(() {
    _tasks.removeAt(index);
  });
}

class _myscreenState extends State<myscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello todolist"),
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: "Enter task"),
                ),
              ),
              IconButton(onPressed: _addTask, icon: Icon(Icons.add),),
            ],
          ),

          ),

        ],
      ),
    );
  }
}
