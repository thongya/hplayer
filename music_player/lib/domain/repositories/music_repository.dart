import '../entities/track.dart';

abstract class MusicRepository {
  Future<List<Track>> getTracks();
  Future<void> playTrack(Track track);
}