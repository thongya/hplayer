
import '../../domain/entities/track.dart';

class TrackModel extends Track {
  TrackModel({
    required String id,
    required String title,
    required String artist,
    required String url,
  }) : super(id: id, title: title, artist: artist, url: url);

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      url: json['url'],
    );
  }
}