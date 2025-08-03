// playlist_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'playlist_manager.dart';
import '../models/audio_model.dart';

class PlaylistScreen extends StatefulWidget {
  final List<AudioFile> allSongs;

  const PlaylistScreen({super.key, required this.allSongs});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final playlistManager = Provider.of<PlaylistManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePlaylistDialog,
          ),
        ],
      ),
      body: playlistManager.playlists.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_music, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No playlists yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Create your first playlist',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: playlistManager.playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlistManager.playlists[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.queue_music,
                  color: Colors.blue,
                ),
              ),
              title: Text(playlist.name),
              subtitle: Text('${playlist.songs.length} songs'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDeletePlaylist(playlist.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
              onTap: () {
                playlistManager.setCurrentPlaylist(playlist);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    _nameController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Playlist'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Playlist Name',
              hintText: 'Enter playlist name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty) {
                  final playlistManager = Provider.of<PlaylistManager>(
                    context,
                    listen: false,
                  );
                  playlistManager.createPlaylist(
                    _nameController.text.trim(),
                    [],
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePlaylist(String playlistId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Playlist'),
          content: const Text('Are you sure you want to delete this playlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final playlistManager = Provider.of<PlaylistManager>(
                  context,
                  listen: false,
                );
                playlistManager.deletePlaylist(playlistId);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}