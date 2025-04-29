import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main(){
  runApp(MyApp2());
}
class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHome(),
    );
  }
}
class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

@override
void initState() {
  super.initState();
  _fetchData();
}
Future<void> _fetchData() async{
  try {
    final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _data = data['title'];
      });
      print(data);
    } else {
      throw Exception('Failed to load data');
    }
  }catch(e){
    setState(() {
      _data = "An error occured: $e";
    });
  }
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

