// audio_service_handler.dart
import 'package:audio_service/audio_service.dart';
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

      mediaItem.add(_createMediaItem(_currentIndex));
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
      artist: 'Unknown Artist',
      album: 'Unknown Album',
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

  Future<void> setPlaylist(List<AudioFile> playlist, int startIndex) async {
    _playlist.clear();
    _playlist.addAll(playlist);
    _currentIndex = startIndex;
    await _loadAndPlay(startIndex);
  }

  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await _loadAndPlay(index);
    }
  }

  Future<void> _loadAndPlay(int index) async {
    if (_playlist.isEmpty || index >= _playlist.length) return;

    try {
      await _player.setFilePath(_playlist[index].path);
      await _player.play();
    } catch (e) {
      print('Error playing audio: $e');
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