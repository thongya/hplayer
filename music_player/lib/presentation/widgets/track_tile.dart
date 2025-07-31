import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track.dart';
import '../providers/player_provider.dart';

class TrackTile extends ConsumerWidget {
  final Track track;

  const TrackTile({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.audiotrack),
      title: Text(track.title),
      subtitle: Text(track.artist),
      onTap: () async {
        await ref.read(playTrackProvider).call(track);
        ref.read(playbackStateProvider.notifier).state = PlaybackState(isPlaying: true, currentTrack: track);
      },
    );
  }
}