import 'package:just_audio/just_audio.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/music_repository.dart';
import '../models/track_model.dart';

class MusicRepositoryImpl implements MusicRepository {
  final AudioPlayer audioPlayer;

  MusicRepositoryImpl(this.audioPlayer);

  @override
  Future<List<Track>> getTracks() async {
    // Simulated data (replace with real API call)
    return [
      TrackModel(
        id: '1',
        title: 'Sample Track',
        artist: 'Sample Artist',
        url: 'https://example.com/sample.mp3',
      ),
    ];
  }

  @override
  Future<void> playTrack(Track track) async {
    try {
      await audioPlayer.setUrl(track.url);
      await audioPlayer.play();
      Logger.log('Playing track: ${track.title}');
    } catch (e) {
      Logger.log('Error playing track: $e');
      rethrow;
    }
  }
}