import 'package:flutter/material.dart';
import '../../domain/entities/genre.dart';

class GenreTile extends StatelessWidget {
  final Genre genre;

  const GenreTile({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.music_note),
      title: Text(genre.name),
      onTap: () {
        // TODO: Navigate to genre detail screen
      },
    );
  }
}