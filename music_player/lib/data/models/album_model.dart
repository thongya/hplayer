import '../../domain/entities/album.dart';

class AlbumModel extends Album {
  AlbumModel({
    required String id,
    required String title,
    required String artist,
    required String coverUrl,
  }) : super(id: id, title: title, artist: artist, coverUrl: coverUrl);

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      coverUrl: json['coverUrl'],
    );
  }
}