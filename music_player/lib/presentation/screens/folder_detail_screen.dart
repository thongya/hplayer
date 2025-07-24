import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class FolderDetailScreen extends StatelessWidget {
  final String id;

  const FolderDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Folder $id')),
      body: Center(
        child: Text('Folder details for ID: $id\n(TODO: Show folder tracks)'),
      ),
    );
  }
}