import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => AudioPlayerService(),
        child: const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTPlayer',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final _audioQuery = const OnAudioQuery();
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    await _audioQuery.permissionsRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTPlayer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.equalizer),
            onPressed: () => showEqualizer(context),
          ),
        ],
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: SongSortType.DISPLAY_NAME,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final songs = snapshot.data!;
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) => ListTile(
              leading: QueryArtworkWidget(
                id: songs[index].id,
                type: ArtworkType.AUDIO,
                artworkHeight: 50,
                artworkWidth: 50,
              ),
              title: Text(songs[index].title),
              subtitle: Text(songs[index].artist ?? 'Unknown Artist'),
              onTap: () =>
                  context.read<AudioPlayerService>().playSong(songs[index]),
            ),
          );
        },
      ),
      bottomNavigationBar: const NowPlayingBar(),
    );
  }

  void showEqualizer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const EqualizerScreen(),
    );
  }
}

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    final playerService = context.watch<AudioPlayerService>();
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              leading: QueryArtworkWidget(
                id: playerService.currentSong?.id ?? 0,
                type: ArtworkType.AUDIO,
                artworkHeight: 50,
                artworkWidth: 50,
              ),
              title:
                  Text(playerService.currentSong?.title ?? 'No song playing'),
              subtitle:
                  Text(playerService.currentSong?.artist ?? 'Unknown Artist'),
            ),
          ),
          IconButton(
            icon:
                Icon(playerService.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: playerService.togglePlayback,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: playerService.playNext,
          ),
        ],
      ),
    );
  }
}

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel>? _playlist;
  SongModel? _currentSong;
  bool _isPlaying = false;

  SongModel? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;

  Future<void> playSong(SongModel song) async {
    _currentSong = song;
    await _audioPlayer.setFilePath(song.data);
    await _audioPlayer.play();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  Future<void> playNext() async {
    // Implement playlist logic
  }

  Future<void> playPrevious() async {
    // Implement playlist logic
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Equalizer', style: TextStyle(fontSize: 20)),
          // Implement equalizer controls
          Slider(
            value: 0.5,
            onChanged: (value) {},
            label: 'Bass',
          ),
        ],
      ),
    );
  }
}
