import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: mobile_responsive(),
  ));
}

class mobile_responsive extends StatelessWidget {
  mobile_responsive({super.key});

  final List<String> flagUrls = [
    'https://flagcdn.com/w320/bd.png',
    'https://flagcdn.com/w320/gb.png',
    'https://flagcdn.com/w320/fr.png',
    'https://flagcdn.com/w320/us.png',
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth < 768)
        ? 2
        : (screenWidth > 1024)
        ? 4
        : 3;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Responsive'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            itemCount: flagUrls.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: NetworkImage(flagUrls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
      ),
    );
  }
}