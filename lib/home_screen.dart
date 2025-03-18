import 'dart:io';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final List<FileSystemEntity> songs;

  HomeScreen({required this.songs});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FileSystemEntity> recentSongs = [];

  @override
  void initState() {
    super.initState();
    // For demonstration, picking the first 5 songs as recently played
    recentSongs = widget.songs.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Music App'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Songs',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),
          // Recently Played
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Recently Played',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentSongs.length,
              itemBuilder: (context, index) {
                String fileName = recentSongs[index].path.split('/').last;
                return GestureDetector(
                  onTap: () {
                    // Play the song
                  },
                  child: Container(
                    width: 120,
                    margin: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // Placeholder for album art
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.music_note,
                            size: 50,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Additional sections like Playlists can be added similarly
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: 'Playlists',
          ),
        ],
        onTap: (index) {
          // Navigate between screens
        },
      ),
    );
  }
}
