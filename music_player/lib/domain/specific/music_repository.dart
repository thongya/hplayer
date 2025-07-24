import '../entities/track.dart';
import '../entities/album.dart';
import '../entities/artist.dart';
import '../entities/folder.dart';
import '../entities/genre.dart';
import '../entities/track.dart';

abstract class MusicRepository {
  Future<List<Track>> getTracks();
  Future<List<Album>> getAlbums();
  Future<List<Artist>> getArtists();
  Future<List<Folder>> getFolders();
  Future<List<Genre>> getGenres();
  Future<void> playTrack(Track track);
}