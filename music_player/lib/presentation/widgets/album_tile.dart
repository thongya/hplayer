import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/album.dart';

class AlbumTile extends StatelessWidget {
  final Album album;

  const AlbumTile({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.album),
      title: Text(album.title),
      subtitle: Text(album.artist),
      onTap: () {
        context.go('/album/${album.id}');
      },
    );
  }
}