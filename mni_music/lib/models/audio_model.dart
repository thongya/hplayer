import 'package:equatable/equatable.dart';

class AudioFile extends Equatable {
  final String name;
  final String path;
  final int? duration; // in seconds
  final String? artist;
  final String? album;

  const AudioFile({
    required this.name,
    required this.path,
    this.duration,
    this.artist,
    this.album,
  });

  AudioFile copyWith({
    String? name,
    String? path,
    int? duration,
    String? artist,
    String? album,
  }) {
    return AudioFile(
      name: name ?? this.name,
      path: path ?? this.path,
      duration: duration ?? this.duration,
      artist: artist ?? this.artist,
      album: album ?? this.album,
    );
  }

  @override
  List<Object?> get props => [name, path, duration, artist, album];
}