import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  List<FileSystemEntity> songs = await fetchAudioFiles();
  runApp(MyApp(songs: songs));
}

Future<void> requestPermissions() async {
  await Permission.storage.request();
}

Future<List<FileSystemEntity>> fetchAudioFiles() async {
  final dir = Directory('/storage/emulated/0/');
  return dir.list(recursive: true).where((file) {
    final ext = file.path
        .split('.')
        .last
        .toLowerCase();
    return ['mp3', 'aac', 'wav', 'flac', 'm4a'].contains(ext);
  }).toList();
}

class MyApp extends StatelessWidget {
  final List<FileSystemEntity> songs;

  MyApp({required this.songs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Music App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomeScreen(songs: songs),
    );
  }
}
