import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/track.dart';
import '../providers/player_provider.dart';
import '../widgets/track_tile.dart';

class AlbumDetailScreen extends ConsumerWidget {
  final String id;

  const AlbumDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock tracks for this album (replace with real API call)
    final tracksFuture = Future.value([
      Track(
        id: '1',
        title: 'Sample Track in Album',
        artist: 'Sample Artist',
        url: AppConstants.defaultAudioUrl,
      ),
    ]);

    return Scaffold(
      appBar: AppBar(title: Text('Album $id')),
      body: FutureBuilder<List<Track>>(
        future: tracksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading tracks: ${snapshot.error}'));
          }
          final tracks = snapshot.data ?? [];
          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) => TrackTile(track: tracks[index]),
          );
        },
      ),
    );
  }
}