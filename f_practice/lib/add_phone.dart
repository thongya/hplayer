import 'package:f_practice/image_grid.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp33());
}

class MyApp33 extends StatelessWidget {
  const MyApp33({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeScreen11();
  }
}

class HomeScreen11 extends StatefulWidget {
  const HomeScreen11({super.key});

  @override
  State<HomeScreen11> createState() => _HomeScreen11State();
}

class _HomeScreen11State extends State<HomeScreen11> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<Map<String, dynamic>> _contacts = [];

  void _addData() {
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      setState(() {
        _contacts.add({
          'name': _nameController.text,
          'phone': _phoneController.text,
        });
        _nameController.clear();
        _phoneController.clear();
      });
    }
  }

  void _deleteData(int index) {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
          title: Text('Delete Contact'),
          content: Text('Are you sure you want to delete this contact?'),
          actions: [
          TextButton(onPressed: ()
      {
        Navigator.of(context).pop();
      }, child: Text('Cancel')
      ),
      TextButton(onPressed: () {
      setState(() {
      _contacts.removeAt(index);
      });
      Navigator.of(context).pop();
      },
      child: Text('Delete', style: TextStyle(color: Colors.red,)),
      ),
      ],
      );
    },
    );
  }

        @override
        Widget build(BuildContext context)
    {
      return Scaffold(
        appBar: AppBar(title: Text("Contact List")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Enter name'),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Enter name'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                  onPressed: _addData,
                  child: Text('add')

              ),
              Expanded(child: ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_contacts[index]['name']!),
                      subtitle: Text(_contacts[index]['phone']!),
                      onLongPress: () => _deleteData(index),
                    );
                  }))
            ],
          ),
        ),
      );
    }
  }
