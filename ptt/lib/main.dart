import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Column(
                children: [
                  Container(
                    // padding: EdgeInsets.all(20),
                    // height: 250,
                    // width: 250,
                    decoration:
                        BoxDecoration(
                            // color: Colors.green,
                            // shape: BoxShape.circle,
                          // borderRadius: BorderRadius.circular(50)
                        ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://letsenhance.io/static/a31ab775f44858f1d1b80ee51738f4f3/11499/EnhanceAfter.jpg',),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Text("Hello world"),
                  Text("Hee ami")
                ],
              )
            ],
          ),
          Row(
            children: [
              Column(
                children: [
                  Icon(Icons.notification_important, size: 50,),
                ]
              )
            ],
          )
        ],
      ),
    );
  }
}
