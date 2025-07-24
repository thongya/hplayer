import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/themes/app_theme.dart';
import 'presentation/screens/album_detail_screen.dart';
import 'presentation/screens/artist_detail_screen.dart';
import 'presentation/screens/folder_detail_screen.dart';
import 'presentation/screens/genre_detail_screen.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MusicPlayerApp()));
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/album/:id',
          builder: (context, state) =>
              AlbumDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/artist/:id',
          builder: (context, state) =>
              ArtistDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/folder/:id',
          builder: (context, state) =>
              FolderDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/genre/:id',
          builder: (context, state) =>
              GenreDetailScreen(id: state.pathParameters['id']!),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Music Player',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
