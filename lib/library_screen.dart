import 'dart:io';
import 'package:flutter/material.dart';
import 'main.dart';
import 'now_playing_screen.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<FileSystemEntity> songs = [];

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  void fetchSongs() async {
    List<FileSystemEntity> files = await fetchAudioFiles();
    setState(() {
      songs = files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library'),
        backgroundColor: Colors.deepPurple,
      ),
      body: songs.isNotEmpty
          ? ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          String fileName = songs[index].path.split('/').last;
          return ListTile(
            title: Text(fileName),
            leading: Icon(Icons.music_note),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NowPlayingScreen(
                    songPath: songs[index].path,
                  ),
                ),
              );
            },
          );
        },
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
