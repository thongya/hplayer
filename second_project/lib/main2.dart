import 'package:flutter/material.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeActivity(),
    );
  }
}

class HomeActivity extends StatelessWidget {
  HomeActivity({super.key});

  var MyItems = [
    {"img":"https://images.pexels.com/photos/1133957/pexels-photo-1133957.jpeg","title":"Hummingbird"},
    {"img":"https://images.pexels.com/photos/1133957/pexels-photo-1133957.jpeg","title":"Bird"},
    {"img":"https://images.pexels.com/photos/1133957/pexels-photo-1133957.jpeg","title":"Hasan"},
    {"img":"https://images.pexels.com/photos/1133957/pexels-photo-1133957.jpeg","title":"Rakib"},
  ];
  mySnackBar(context, msg){
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory App"),
      ),
      body: ListView.builder(
        itemCount: MyItems.length,
        itemBuilder: (context, index){
          return GestureDetector(
            onTap: (){mySnackBar(context, MyItems[index]['title']);},
            child: Container(
              margin: EdgeInsets.all(10),
              width: double.infinity,
              height: 150,
              child: Image.network(MyItems[index]['img']!, fit: BoxFit.fill,),
            ),
          );
        },
      ),
    );
  }
}