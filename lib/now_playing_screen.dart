import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class NowPlayingScreen extends StatefulWidget {
  final String songPath;

  NowPlayingScreen({required this.songPath});

  @override
  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  late AudioPlayer _player;
  bool isPlaying = false;
  Duration duration = Duration();
  Duration position = Duration();

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    setupPlayer();
  }

  void setupPlayer() async {
    await _player.setFilePath(widget.songPath);
    _player.durationStream.listen((d) {
      setState(() {
        duration = d ?? Duration();
      });
    });
    _player.positionStream.listen((p) {
      setState(() {
        position = p;
      });
    });
  }

  void playPause() {
    if (isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  String formatTime(Duration time) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(time.inMinutes.remainder(60))}:${twoDigits(time.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String fileName = widget.songPath.split('/').last;
    return Scaffold(
      appBar: AppBar(
        title: Text('Now Playing'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art Placeholder
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.music_note,
              size: 100,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 30),
          // Song Title
          Text(
            fileName,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Artist Name Placeholder
          Text(
            'Unknown Artist',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 30),
          // Progress Bar
          Slider(
            activeColor: Colors.deepPurple,
            inactiveColor: Colors.deepPurple[100],
            min: 0.0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: (double value) {
              setState(() {
                _player.seek(Duration(seconds: value.toInt()));
              });
            },
          ),
          // Time Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTime(position)),
                Text(formatTime(duration)),
              ],
            ),
          ),
          SizedBox(height: 30),
          // Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 45,
                icon: Icon(Icons.skip_previous),
                onPressed: () {
                  // Implement skip previous
                },
              ),
              IconButton(
                iconSize: 62,
                icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                onPressed: playPause,
              ),
              IconButton(
                iconSize: 45,
                icon: Icon(Icons.skip_next),
                onPressed: () {
                  // Implement skip next
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          // Additional Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shuffle),
                onPressed: () {
                  // Implement shuffle
                },
              ),
              IconButton(
                icon: Icon(Icons.repeat),
                onPressed: () {
                  // Implement repeat
                },
              ),
              IconButton(
                icon: Icon(Icons.queue_music),
                onPressed: () {
                  // Show queue
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
