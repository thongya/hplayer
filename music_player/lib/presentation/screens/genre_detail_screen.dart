import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class GenreDetailScreen extends StatelessWidget {
  final String id;

  const GenreDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Genre $id')),
      body: Center(
        child: Text('Genre details for ID: $id\n(TODO: Show genre tracks)'),
      ),
    );
  }
}