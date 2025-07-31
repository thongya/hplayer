import 'package:flutter/material.dart';

class ArtistDetailScreen extends StatelessWidget {
  final String id;

  const ArtistDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Artist $id')),
      body: Center(
        child: Text('Artist details for ID: $id\n(TODO: Show artist tracks or albums)'),
      ),
    );
  }
}