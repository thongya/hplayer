import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeActivity(),
    );
  }
}

final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: EdgeInsets.all(10),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))));

class HomeActivity extends StatelessWidget {
  const HomeActivity({super.key});

  MyAlertDialog(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Expanded(
              child: AlertDialog(
                title: Text("Alert !"),
                content: Text("Do you want to delete"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Yes")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("No"))
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory App"),
      ),
      body: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        SizedBox(
          height: 100,
          width: 100,
          child: Image.network(
              'https://unsplash.com/photos/young-asian-travel-woman-is-enjoying-with-beautiful-place-in-bangkok-thailand-_Fqoswmdmoo'),
        ),
        Container(
          height: 100,
          width: 100,
          child: Image.network(
              'https://unsplash.com/photos/young-asian-travel-woman-is-enjoying-with-beautiful-place-in-bangkok-thailand-_Fqoswmdmoo'),
        ),
        Container(
          height: 100,
          width: 100,
          child: Image.network(
              'https://unsplash.com/photos/young-asian-travel-woman-is-enjoying-with-beautiful-place-in-bangkok-thailand-_Fqoswmdmoo'),
        ),
        TextButton(
            onPressed: () {
              Text("Hello text button");
            },
            child: Text("Text button")),
        ElevatedButton(
          onPressed: () {
            MyAlertDialog(context);
          },
          child: Text("Elevated button"),
          style: buttonStyle,
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'First Name')),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () {},
            child: Text("Submit"),
          ),
        )
      ]),
    );
  }
}
