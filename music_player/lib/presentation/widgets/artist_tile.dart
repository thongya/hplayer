import '../../domain/entities/artist.dart';

class ArtistModel extends Artist {
  ArtistModel({required String id, required String name}) : super(id: id, name: name);

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(id: json['id'], name: json['name']);
  }
}