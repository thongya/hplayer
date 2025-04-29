import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp1());
}
class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScre()
    );
  }
}

class HomeScre extends StatelessWidget {
  const HomeScre({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://imgv3.fotor.com/images/slider-image/A-clear-close-up-photo-of-a-woman.jpg'),
                  )
                ]
              ),
              Row(
                children: [
                  Text("Logue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 29),)
                ],
              ),
              Row(
                children: [
                  Icon(Icons.search, size: 35,)
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 25),
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(color: Colors.grey),
                      )
                    ],
                  ),
                ],
              )
            ]
          )
        ],
      ),

    );
  }
}

