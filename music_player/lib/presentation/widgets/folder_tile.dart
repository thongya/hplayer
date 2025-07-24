import 'package:flutter/material.dart';
import '../../domain/entities/folder.dart';

class FolderTile extends StatelessWidget {
  final Folder folder;

  const FolderTile({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(folder.name),
      subtitle: Text(folder.path),
      onTap: () {
        // TODO: Navigate to folder detail screen
      },
    );
  }
}