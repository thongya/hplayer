import 'package:flutter/material.dart';
import 'package:mini_music/player_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart' as path;

class FolderBrowserScreen extends StatefulWidget {
  const FolderBrowserScreen({super.key});

  @override
  State<FolderBrowserScreen> createState() => _FolderBrowserScreenState();
}

class _FolderBrowserScreenState extends State<FolderBrowserScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<String> _folders = [];
  List<SongModel> _songs = [];
  String? _currentFolder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() => _isLoading = true);
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.DISPLAY_NAME,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );

    final folderSet = <String>{};
    for (final song in songs) {
      if (song.data != null) {
        final dir = path.dirname(song.data!);
        folderSet.add(dir);
      }
    }

    setState(() {
      _folders = folderSet.toList();
      _isLoading = false;
    });
  }

  Future<void> _loadSongsFromFolder(String folder) async {
    setState(() {
      _isLoading = true;
      _currentFolder = folder;
    });

    final allSongs = await _audioQuery.querySongs();
    _songs = allSongs.where((song) {
      return song.data != null && path.dirname(song.data!) == folder;
    }).toList();

    setState(() => _isLoading = false);
  }

  void _navigateBack() {
    setState(() {
      _currentFolder = null;
      _songs = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentFolder != null
            ? path.basename(_currentFolder!)
            : 'Folders'),
        leading: _currentFolder != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentFolder != null
          ? _songs.isEmpty
          ? const Center(child: Text('No songs in this folder'))
          : ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          return ListTile(
            leading: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: const Icon(Icons.music_note),
            ),
            title: Text(song.displayNameWOExt),
            subtitle: Text(song.artist ?? "<Unknown>"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerScreen(
                    songs: _songs,
                    initialIndex: index,
                  ),
                ),
              );
            },
          );
        },
      )
          : _folders.isEmpty
          ? const Center(child: Text('No folders found'))
          : ListView.builder(
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          return ListTile(
            leading: const Icon(Icons.folder),
            title: Text(path.basename(folder)),
            onTap: () => _loadSongsFromFolder(folder),
          );
        },
      ),
    );
  }
}