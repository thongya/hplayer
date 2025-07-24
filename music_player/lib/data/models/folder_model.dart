import '../../domain/entities/folder.dart';

class FolderModel extends Folder {
  FolderModel({required String id, required String name, required String path})
      : super(id: id, name: name, path: path);

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(id: json['id'], name: json['name'], path: json['path']);
  }
}