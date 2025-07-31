import 'package:just_audio/just_audio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/track.dart';
import '../../domain/specific/music_repository.dart';
import '../models/album_model.dart';
import '../models/artist_model.dart';
import '../models/folder_model.dart';
import '../models/genre_model.dart';
import '../models/track_model.dart';

class MusicRepositoryImpl implements MusicRepository {
  final AudioPlayer audioPlayer;

  MusicRepositoryImpl(this.audioPlayer);

  @override
  Future<List<Track>> getTracks() async {
    return [
      TrackModel(
        id: '1',
        title: 'Sample Track',
        artist: 'Sample Artist',
        url: AppConstants.defaultAudioUrl,
      ),
    ];
  }

  @override
  Future<List<Album>> getAlbums() async {
    return [
      AlbumModel(
        id: '1',
        title: 'Sample Album',
        artist: 'Sample Artist',
        coverUrl: 'https://example.com/sample_cover.jpg',
      ),
    ];
  }

  @override
  Future<List<Artist>> getArtists() async {
    return [
      ArtistModel(id: '1', name: 'Sample Artist'),
    ];
  }

  @override
  Future<List<Folder>> getFolders() async {
    return [
      FolderModel(id: '1', name: 'Music Folder', path: '/storage/music'),
    ];
  }

  @override
  Future<List<Genre>> getGenres() async {
    return [
      GenreModel(id: '1', name: 'Pop'),
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