import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/repositories/music_repository_impl.dart';
import '../../data/services/audio_service.dart';
import '../../domain/entities/track.dart';
import '../../domain/usecases/play_track.dart';

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final musicRepositoryProvider = Provider((ref) {
  return MusicRepositoryImpl(ref.read(audioServiceProvider).player);
});

final playTrackProvider = Provider((ref) {
  return PlayTrack(ref.read(musicRepositoryProvider));
});

final playbackStateProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return PlaybackNotifier(audioService.player)..listenToPlayer();
});

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final AudioPlayer _player;

  PlaybackNotifier(this._player) : super(PlaybackState(isPlaying: false, currentTrack: null));

  void listenToPlayer() {
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      // You can optionally store more info like duration/position here
      state = PlaybackState(isPlaying: isPlaying, currentTrack: state.currentTrack);
    });
  }

  void setTrack(Track? track) {
    state = PlaybackState(isPlaying: state.isPlaying, currentTrack: track);
  }
}

class PlaybackState {
  final bool isPlaying;
  final Track? currentTrack;

  PlaybackState({required this.isPlaying, this.currentTrack});
}