import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'player_screen.dart';
import 'folder_browser_screen.dart';
import 'playlist_screen.dart';
import 'settings_screen.dart';
import 'theme_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> songs = [];
  List<SongModel> filteredSongs = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
    _searchController.addListener(_filterSongs);
  }

  Future<void> _fetchSongs() async {
    setState(() => _isLoading = true);
    songs = await _audioQuery.querySongs(
      sortType: SongSortType.DISPLAY_NAME,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
    filteredSongs = List.from(songs);
    setState(() => _isLoading = false);
  }

  void _filterSongs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSongs = songs.where((song) {
        return song.displayNameWOExt.toLowerCase().contains(query) ||
            (song.artist?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FolderBrowserScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlaylistScreen()),
            ),
          ),
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return IconButton(
                icon: Icon(themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => themeService.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search songs...',
                border: InputBorder.none,
                icon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterSongs();
                  },
                )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredSongs.isEmpty
          ? const Center(child: Text('No songs found'))
          : ListView.builder(
        itemCount: filteredSongs.length,
        itemBuilder: (context, index) {
          final song = filteredSongs[index];
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
                    songs: songs,
                    initialIndex: songs.indexOf(song),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}