import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/track.dart';
import '../providers/player_provider.dart';
import '../widgets/album_tile.dart';
import '../widgets/artist_tile.dart';
import '../widgets/folder_tile.dart';
import '../widgets/genre_tile.dart';
import '../widgets/track_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicRepository = ref.read(musicRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Songs'),
            Tab(text: 'Albums'),
            Tab(text: 'Artists'),
            Tab(text: 'Folders'),
            Tab(text: 'Genres'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Songs Tab
          FutureBuilder<List<Track>>(
            future: musicRepository.getTracks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading tracks: ${snapshot.error}'));
              }
              final tracks = snapshot.data ?? [];
              return ListView.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) => TrackTile(track: tracks[index]),
              );
            },
          ),
          // Albums Tab
          FutureBuilder<List<Album>>(
            future: musicRepository.getAlbums(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading albums: ${snapshot.error}'));
              }
              final albums = snapshot.data ?? [];
              return ListView.builder(
                itemCount: albums.length,
                itemBuilder: (context, index) => AlbumTile(album: albums[index]),
              );
            },
          ),
          // Artists Tab
          FutureBuilder<List<Artist>>(
            future: musicRepository.getArtists(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading artists: ${snapshot.error}'));
              }
              final artists = snapshot.data ?? [];
              return ListView.builder(
                itemCount: artists.length,
                itemBuilder: (context, index) => ArtistTile(artist: artists[index]),
              );
            },
          ),
          // Folders Tab
          FutureBuilder<List<Folder>>(
            future: musicRepository.getFolders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading folders: ${snapshot.error}'));
              }
              final folders = snapshot.data ?? [];
              return ListView.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) => FolderTile(folder: folders[index]),
              );
            },
          ),
          // Genres Tab
          FutureBuilder<List<Genre>>(
            future: musicRepository.getGenres(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading genres: ${snapshot.error}'));
              }
              final genres = snapshot.data ?? [];
              return ListView.builder(
                itemCount: genres.length,
                itemBuilder: (context, index) => GenreTile(genre: genres[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}