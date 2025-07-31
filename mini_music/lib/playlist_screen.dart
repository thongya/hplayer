import 'package:flutter/material.dart';
import 'package:mini_music/player_screen.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<Map<String, dynamic>> _playlists = [];
  List<SongModel> _allSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
    _loadSongs();
  }

  Future<void> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = prefs.getStringList('playlists') ?? [];
    setState(() {
      _playlists = playlistsJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _loadSongs() async {
    _allSongs = await _audioQuery.querySongs();
    setState(() => _isLoading = false);
  }

  Future<void> _createPlaylist() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Playlist'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Playlist name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final name = controller.text;
                final newPlaylist = {
                  'name': name,
                  'songs': <int>[],
                };

                setState(() {
                  _playlists.add(newPlaylist);
                });

                final prefs = await SharedPreferences.getInstance();
                final playlistsJson = prefs.getStringList('playlists') ?? [];
                playlistsJson.add(jsonEncode(newPlaylist));
                await prefs.setStringList('playlists', playlistsJson);

                Navigator.pop(context);
                _showAddSongsDialog(newPlaylist);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddSongsDialog(Map<String, dynamic> playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistSongSelector(
          allSongs: _allSongs,
          playlist: playlist,
          onSongsAdded: (updatedPlaylist) async {
            final prefs = await SharedPreferences.getInstance();
            final playlistsJson = prefs.getStringList('playlists') ?? [];
            final index = _playlists.indexWhere((p) => p['name'] == playlist['name']);

            if (index != -1) {
              _playlists[index] = updatedPlaylist;
              playlistsJson[index] = jsonEncode(updatedPlaylist);
              await prefs.setStringList('playlists', playlistsJson);
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createPlaylist,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlists.isEmpty
          ? const Center(child: Text('No playlists found'))
          : ListView.builder(
        itemCount: _playlists.length,
        itemBuilder: (context, index) {
          final playlist = _playlists[index];
          final songCount = playlist['songs'].length;

          return ListTile(
            leading: const Icon(Icons.playlist_play),
            title: Text(playlist['name']),
            subtitle: Text('$songCount songs'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  _showAddSongsDialog(playlist);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(playlist);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistPlayerScreen(
                    playlist: playlist,
                    allSongs: _allSongs,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: Text('Are you sure you want to delete "${playlist['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _playlists.removeWhere((p) => p['name'] == playlist['name']);
              });

              final prefs = await SharedPreferences.getInstance();
              final playlistsJson = prefs.getStringList('playlists') ?? [];
              playlistsJson.removeWhere((json) {
                final p = jsonDecode(json) as Map<String, dynamic>;
                return p['name'] == playlist['name'];
              });
              await prefs.setStringList('playlists', playlistsJson);

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class PlaylistSongSelector extends StatefulWidget {
  final List<SongModel> allSongs;
  final Map<String, dynamic> playlist;
  final Function(Map<String, dynamic>) onSongsAdded;

  const PlaylistSongSelector({
    super.key,
    required this.allSongs,
    required this.playlist,
    required this.onSongsAdded,
  });

  @override
  State<PlaylistSongSelector> createState() => _PlaylistSongSelectorState();
}

class _PlaylistSongSelectorState extends State<PlaylistSongSelector> {
  late List<SongModel> _songs;
  late Set<int> _selectedSongIds;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _songs = List.from(widget.allSongs);
    _selectedSongIds = Set<int>.from(widget.playlist['songs']);
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add songs to ${widget.playlist['name']}'),
        actions: [
          TextButton(
            onPressed: () {
              final updatedPlaylist = Map<String, dynamic>.from(widget.playlist);
              updatedPlaylist['songs'] = _selectedSongIds.toList();
              widget.onSongsAdded(updatedPlaylist);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          final isSelected = _selectedSongIds.contains(song.id);

          return CheckboxListTile(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedSongIds.add(song.id);
                } else {
                  _selectedSongIds.remove(song.id);
                }
              });
            },
            secondary: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: const Icon(Icons.music_note),
            ),
            title: Text(song.displayNameWOExt),
            subtitle: Text(song.artist ?? "<Unknown>"),
          );
        },
      ),
    );
  }
}

class PlaylistPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> playlist;
  final List<SongModel> allSongs;

  const PlaylistPlayerScreen({
    super.key,
    required this.playlist,
    required this.allSongs,
  });

  @override
  State<PlaylistPlayerScreen> createState() => _PlaylistPlayerScreenState();
}

class _PlaylistPlayerScreenState extends State<PlaylistPlayerScreen> {
  late List<SongModel> _playlistSongs;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  void _loadPlaylistSongs() {
    final songIds = List<int>.from(widget.playlist['songs']);
    _playlistSongs = widget.allSongs.where((song) => songIds.contains(song.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist['name']),
      ),
      body: _playlistSongs.isEmpty
          ? const Center(child: Text('No songs in this playlist'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _playlistSongs.length,
              itemBuilder: (context, index) {
                final song = _playlistSongs[index];
                return ListTile(
                  leading: QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: const Icon(Icons.music_note),
                  ),
                  title: Text(song.displayNameWOExt),
                  subtitle: Text(song.artist ?? "<Unknown>"),
                  onTap: () {
                    setState(() => _currentIndex = index);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(
                          songs: _playlistSongs,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  trailing: index == _currentIndex
                      ? const Icon(Icons.play_arrow, color: Colors.green)
                      : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(
                      songs: _playlistSongs,
                      initialIndex: _currentIndex,
                    ),
                  ),
                );
              },
              child: const Text('Play All'),
            ),
          ),
        ],
      ),
    );
  }
}