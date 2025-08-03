// playlist_model.dart
import 'package:equatable/equatable.dart';
import '../models/audio_model.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final List<AudioFile> songs;
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.name,
    required this.songs,
    required this.createdAt,
  });

  Playlist copyWith({
    String? id,
    String? name,
    List<AudioFile>? songs,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? this.songs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, songs, createdAt];
}