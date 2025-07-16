import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/track.dart';
import '../providers/player_provider.dart';
import '../widgets/track_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackListFuture = ref.read(musicRepositoryProvider).getTracks();

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: FutureBuilder<List<Track>>(
        future: trackListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading tracks: ${snapshot.error}'));
          }
          final trackList = snapshot.data ?? [];
          return ListView.builder(
            itemCount: trackList.length,
            itemBuilder: (context, index) => TrackTile(track: trackList[index]),
          );
        },
      ),
    );
  }
}