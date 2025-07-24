import '../../domain/entities/genre.dart';

class GenreModel extends Genre {
  GenreModel({required String id, required String name}) : super(id: id, name: name);

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(id: json['id'], name: json['name']);
  }
}