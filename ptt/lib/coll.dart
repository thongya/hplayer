import 'package:flutter/material.dart';

void main() {
  runApp(const app1());
}

class app1 extends StatelessWidget {
  const app1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: homeScr(),
    );
  }
}

class homeScr extends StatelessWidget {
  const homeScr({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(50)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      'images/img.jpg',
                      fit: BoxFit.cover,
                    )),
              ),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(Icons.file_copy_outlined),
                  ),
                  Column(
                      children: [Icon(Icons.notification_important_outlined)])
                ],
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Text(
                'Hello',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.waving_hand,
                color: Colors.yellow,
                size: 30,
              )
            ],
          ),
          Row(
            children: [
              Text("Luca Romano",
              style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold),
              )
            ],
          ),
          SizedBox(height: 10,),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 100,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text("Today"),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Column(
                    children: [
                      Container(
                        height: 100,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(child: Text("Learning plan", style: TextStyle(),)),
                      ),
                    ]
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 210,
                        width: 450,
                        decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 200,
                                width: 215,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'images/photoo.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    height: 50,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(child: Text("hjj")),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Text("Lesson 1 - 5"),
                                ],
                              )
                            ],
                          ),
                        )
                      ),
                    ]
                  )
                ]
              )
            ],
          )
        ],
      ),

    );
  }
}
