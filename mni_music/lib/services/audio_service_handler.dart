import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_model.dart';

class AudioServiceHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final List<AudioFile> _playlist = [];
  int _currentIndex = 0;

  AudioServiceHandler() {
    _init();
  }

  Future<void> _init() async {
    // Listen to player events
    _player.playerStateStream.listen((state) {
      final playing = state.playing;
      final processingState = state.processingState;

      // Update media item
      if (_currentIndex < _playlist.length) {
        mediaItem.add(_createMediaItem(_currentIndex));
      }

      // Update playback state
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentIndex,
      ));
    });

    _player.positionStream.listen((position) {
      final state = playbackState.value;
      playbackState.add(state.copyWith(updatePosition: position));
    });

    // Handle completion
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  MediaItem _createMediaItem(int index) {
    if (index < 0 || index >= _playlist.length) {
      return const MediaItem(
        id: 'empty',
        title: 'No Media',
      );
    }

    final song = _playlist[index];
    return MediaItem(
      id: song.path,
      title: song.name,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      duration: song.duration != null ? Duration(milliseconds: song.duration!) : null,
      artUri: null, // You can add album art here if available
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await _loadAndPlay(_currentIndex);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await _loadAndPlay(_currentIndex);
  }

  Future<void> _loadAndPlay(int index) async {
    if (_playlist.isEmpty || index >= _playlist.length || index < 0) return;
    try {
      final file = File(_playlist[index].path);
      if (await file.exists()) {
        await _player.setFilePath(_playlist[index].path);
        mediaItem.add(_createMediaItem(index));
        await _player.play();
      } else {
        print('File not found: ${_playlist[index].path}');
        Fluttertoast.showToast(msg: 'Audio file not found');
        skipToNext(); // Try next track if current file is missing
      }
    } catch (e) {
      print('Error playing audio: $e');
      Fluttertoast.showToast(msg: 'Error playing audio: $e');
    }
  }

  Future<void> setPlaylist(List<AudioFile> playlist, int startIndex) async {
    _playlist.clear();
    _playlist.addAll(playlist);
    _currentIndex = startIndex.clamp(0, playlist.length - 1);

    final mediaItems = playlist.map((song) => MediaItem(
      id: song.path,
      title: song.name,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      duration: song.duration != null ? Duration(seconds: song.duration!) : null,
    )).toList();

    queue.add(mediaItems);

    await _loadAndPlay(_currentIndex);
  }

  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await _loadAndPlay(index);
    }
  }

  // Add method to stop playback (used by sleep timer)
  Future<void> stopPlayback() async {
    await _player.stop();
  }

  @override
  Future<void> onTaskRemoved() async {
    await _player.stop();
    await super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await _player.stop();
    await super.onNotificationDeleted();
  }
}