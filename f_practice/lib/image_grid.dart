import 'package:flutter/material.dart';

void main() {
  runApp(myapp1());
}

class myapp1 extends StatelessWidget {
  const myapp1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter demo',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter widgets')),
      body: ListView(
        children: [
          Image.network(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUPIfiGgUML8G3ZqsNLHfaCnZK3I5g4tJabQ&s',
            width: 200,
            height: 100,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Thongya Murong"),
            subtitle: Text("Flutter Developer"),
            trailing: Icon(Icons.edit),
            // onTap: () => print("Thongya Murong"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grid view')),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 2,
        children: [
          Container(
            color: Colors.red,
            height: 100,
            child: Text(
              'amar name',
              style: TextStyle(color: Colors.white, height: 100),
            ),
          ),
          Container(
            color: Colors.yellow,
            height: 100,
            child: Text(
              'amar name',
              style: TextStyle(color: Colors.greenAccent, height: 100),
            ),
          ),
          Container(
            color: Colors.blue,
            height: 100,
            child: Text(
              'amar name',
              style: TextStyle(color: Colors.orange, height: 100),
            ),
          ),
          Container(
            color: Colors.green,
            height: 100,
            child: Text(
              'amar name',
              style: TextStyle(color: Colors.yellow, height: 100),
            ),
          ),
        ],
      ),
    );
  }
}
