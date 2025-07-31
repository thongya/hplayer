import '../entities/track.dart';
import '../specific/music_repository.dart';

class PlayTrack {
  final MusicRepository repository;

  PlayTrack(this.repository);

  Future<void> call(Track track) async {
    await repository.playTrack(track);
  }
}