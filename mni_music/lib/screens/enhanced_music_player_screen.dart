// lib/screens/enhanced_music_player_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audio_model.dart';
import 'playlist_manager.dart';
import '../services/equalizer_manager.dart';
import 'settings_screen.dart';
import 'playlist_screen.dart';
import '../services/sleep_timer_manager.dart';
import '../services/sleep_timer_dialog.dart';
import '../services/audio_service_handler.dart';

class EnhancedMusicPlayerScreen extends StatefulWidget {
  const EnhancedMusicPlayerScreen({super.key});

  @override
  State<EnhancedMusicPlayerScreen> createState() =>
      _EnhancedMusicPlayerScreenState();
}

class _EnhancedMusicPlayerScreenState extends State<EnhancedMusicPlayerScreen> {
  final logger = Logger();
  List<AudioFile> _audioFiles = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isShuffle = false;
  bool _isRepeat = false;

  // Add AudioServiceHandler reference
  late AudioServiceHandler _audioHandler;

  @override
  void initState() {
    super.initState();
    // Get the AudioServiceHandler from Provider
    _audioHandler = Provider.of<AudioServiceHandler>(context, listen: false);
    _requestPermissions();
    _setupAudioPlayer();
    _loadLastPlayed();
  }

  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => const SleepTimerDialog(),
    );
  }

  void _setupAudioPlayer() {
    // Listen to playback state from AudioService
    _audioHandler.playbackState.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        _position = state.updatePosition;
      });

      // Handle completion
      if (state.processingState == AudioProcessingState.completed) {
        if (_isRepeat) {
          _audioHandler.seek(Duration.zero);
          _audioHandler.play();
        } else {
          _playNext();
        }
      }
    });

    // Listen to media item changes for duration
    _audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null) {
        setState(() {
          _duration = mediaItem.duration ?? Duration.zero;
        });
      }
    });
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      try {
        // Check Android version
        int sdkVersion = int.parse(Platform.version.split(' ')[2]);

        if (sdkVersion >= 33) {
          // Android 13+ (API 33+)
          var status = await Permission.audio.request();
          if (status.isGranted) {
            _loadAudioFiles();
          } else {
            _handlePermissionDenied();
          }
        } else if (sdkVersion >= 30) {
          // Android 11-12 (API 30-32)
          var manageStorageStatus = await Permission.manageExternalStorage.request();
          var storageStatus = await Permission.storage.request();
          if (manageStorageStatus.isGranted || storageStatus.isGranted) {
            _loadAudioFiles();
          } else {
            _handlePermissionDenied();
          }
        } else {
          // Android 10 and below
          var status = await Permission.storage.request();
          if (status.isGranted) {
            _loadAudioFiles();
          } else {
            _handlePermissionDenied();
          }
        }
      } catch (e) {
        print('Error checking Android version: $e');
        // Fallback for all permissions
        var status = await [
          Permission.audio,
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();
        if (status.values.any((status) => status.isGranted)) {
          _loadAudioFiles();
        } else {
          _handlePermissionDenied();
        }
      }
    } else {
      _loadAudioFiles();
    }
  }

  void _handlePermissionDenied() {
    Fluttertoast.showToast(msg: 'Storage permission denied. Please enable in Settings.');
    setState(() {
      _isLoading = false;
    });
    // Show dialog to guide user to settings
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text('Storage permission is needed to access your music files. Please enable it in Settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAudioFiles() async {
    final audioQuery = OnAudioQuery();
    try {
      logger.i('Loading audio file');
      // Check if permission is granted
      bool permissionStatus = await audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await audioQuery.permissionsRequest();
      }

      List<SongModel> songs = await audioQuery.querySongs();
      List<AudioFile> audioFiles = songs.map((song) {
        return AudioFile(
          name: song.title,
          path: song.data,
          duration: (song.duration ?? 0) ~/ 1000, // Convert ms to seconds
          artist: song.artist,
          album: song.album,
        );
      }).toList();

      setState(() {
        _audioFiles = audioFiles;
        _isLoading = false;
      });

      if (audioFiles.isNotEmpty) {
        Fluttertoast.showToast(msg: 'Found ${audioFiles.length} audio files');
      } else {
        Fluttertoast.showToast(msg: 'No audio files found. Please add music files to your device.');
      }
    } catch (e, stackTrace) {
      logger.e('Error loading audio files', error: e, stackTrace: stackTrace);
      print('Error loading audio files: $e');
      Fluttertoast.showToast(msg: 'Error loading audio files: $e');
      setState(() {
        _isLoading = false;
        _audioFiles = [];
      });
    }
  }

  bool _isAudioFile(String fileName) {
    List<String> audioExtensions = [
      '.mp3',
      '.wav',
      '.flac',
      '.m4a',
      '.aac',
      '.ogg',
      '.wma',
    ];
    return audioExtensions.any((ext) => fileName.toLowerCase().endsWith(ext));
  }

  Future<void> _playAudio(int index) async {
    try {
      setState(() {
        _currentIndex = index;
      });

      // Set the playlist and play using AudioService
      await _audioHandler.setPlaylist(_audioFiles, index);
      _saveLastPlayed();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error playing audio: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioHandler.pause();
    } else {
      if (_audioFiles.isNotEmpty) {
        if (_audioHandler.playbackState.value.processingState == AudioProcessingState.completed) {
          await _audioHandler.seek(Duration.zero);
        }
        await _audioHandler.play();
      }
    }
  }

  Future<void> _playNext() async {
    if (_audioFiles.isNotEmpty) {
      int nextIndex;
      if (_isShuffle) {
        nextIndex = (DateTime.now().millisecondsSinceEpoch % _audioFiles.length);
      } else {
        nextIndex = (_currentIndex + 1) % _audioFiles.length;
      }
      await _playAudio(nextIndex);
    }
  }

  Future<void> _playPrevious() async {
    if (_audioFiles.isNotEmpty) {
      int prevIndex = (_currentIndex - 1 + _audioFiles.length) % _audioFiles.length;
      await _playAudio(prevIndex);
    }
  }

  Future<void> _toggleShuffle() async {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Future<void> _toggleRepeat() async {
    setState(() {
      _isRepeat = !_isRepeat;
    });
  }

  Future<void> _saveLastPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_index', _currentIndex);
    await prefs.setString('last_path', _audioFiles[_currentIndex].path);
  }

  Future<void> _loadLastPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt('last_index') ?? 0;
    final lastPath = prefs.getString('last_path');
    if (lastPath != null && lastIndex < _audioFiles.length) {
      setState(() {
        _currentIndex = lastIndex;
      });
    }
  }

  void _showAddToPlaylistDialog(AudioFile song) {
    final playlistManager = Provider.of<PlaylistManager>(
      context,
      listen: false,
    );
    if (playlistManager.playlists.isEmpty) {
      Fluttertoast.showToast(msg: 'Create a playlist first');
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add to Playlist',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...playlistManager.playlists.map((playlist) {
                return ListTile(
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.songs.length} songs'),
                  onTap: () {
                    playlistManager.addSongToPlaylist(playlist.id, song);
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: 'Added to ${playlist.name}');
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
    } else {
      return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistManager = Provider.of<PlaylistManager>(context);
    final equalizerManager = Provider.of<EqualizerManager>(context);
    List<AudioFile> displayedSongs =
        playlistManager.currentPlaylist?.songs ?? _audioFiles;

    return Scaffold(
      appBar: AppBar(
        title: Text(playlistManager.currentPlaylist?.name ?? 'All Songs'),
        actions: [
          Consumer<SleepTimerManager>(
            builder: (context, sleepTimerManager, child) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: sleepTimerManager.isActive,
                  label: sleepTimerManager.isActive
                      ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${sleepTimerManager.timeLeft.inMinutes + 1}',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      : null,
                  child: const Icon(Icons.timer),
                ),
                onPressed: _showSleepTimerDialog,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistScreen(allSongs: _audioFiles),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Playing Info
          if (displayedSongs.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(125),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.music_note,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayedSongs[_currentIndex].name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (equalizerManager.isEnabled) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'EQ: ${equalizerManager.currentPreset}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Progress Bar
          if (displayedSongs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue,
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Colors.blue,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16,
                      ),
                    ),
                    child: Slider(
                      value: _position.inSeconds.toDouble(),
                      min: 0,
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        _audioHandler.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                ],
              ),
            ),
          // Control Buttons
          if (displayedSongs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isShuffle ? Icons.shuffle : Icons.shuffle_outlined,
                          color: _isShuffle ? Colors.blue : null,
                        ),
                        onPressed: _toggleShuffle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 45),
                        onPressed: _playPrevious,
                      ),
                      FloatingActionButton(
                        backgroundColor: Colors.blue,
                        elevation: 8,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 45,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 45),
                        onPressed: _playNext,
                      ),
                      IconButton(
                        icon: Icon(
                          _isRepeat ? Icons.repeat_one : Icons.repeat,
                          color: _isRepeat ? Colors.blue : null,
                        ),
                        onPressed: _toggleRepeat,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Audio Files List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedSongs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.music_off,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    playlistManager.currentPlaylist != null
                        ? 'This playlist is empty'
                        : 'No audio files found',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  if (playlistManager.currentPlaylist == null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Add music files to your device',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadAudioFiles,
              child: ListView.builder(
                itemCount: displayedSongs.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        displayedSongs[index].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        displayedSongs[index].path
                            .split('/')
                            .lastWhere(
                              (element) =>
                          element != displayedSongs[index].name,
                          orElse: () => 'Root',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (playlistManager.currentPlaylist == null)
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () => _showAddToPlaylistDialog(
                                displayedSongs[index],
                              ),
                            ),
                          if (_currentIndex == index)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _isPlaying
                                    ? Colors.blue
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      onTap: () => _playAudio(index),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: playlistManager.currentPlaylist != null
          ? BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                playlistManager.setCurrentPlaylist(null);
              },
              child: const Text('Back to All Songs'),
            ),
            TextButton(
              onPressed: () {
                // Play entire playlist
                if (playlistManager.currentPlaylist!.songs.isNotEmpty) {
                  setState(() {
                    _audioFiles = playlistManager.currentPlaylist!.songs;
                    _currentIndex = 0;
                  });
                  _playAudio(0);
                }
              },
              child: const Text('Play All'),
            ),
          ],
        ),
      )
          : null,
    );
  }

  @override
  void dispose() {
    // Dispose is handled by AudioService
    super.dispose();
  }
}