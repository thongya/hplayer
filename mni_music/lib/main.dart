// main.dart
import 'package:flutter/material.dart';
import 'package:mni_music/services/sleep_timer_manager.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'screens/enhanced_music_player_screen.dart';
import 'theme/theme_manager.dart';
import 'screens/playlist_manager.dart';
import 'services/equalizer_manager.dart';
import 'services/audio_service_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio service
  final audioHandler = await AudioService.init(
    builder: () => AudioServiceHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.yourcompany.musicplayer.channel.audio',
      androidNotificationChannelName: 'Music Player',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => PlaylistManager()),
        ChangeNotifierProvider(create: (_) => EqualizerManager()),
        ChangeNotifierProvider(
          create: (context) {
            final sleepTimerManager = SleepTimerManager();
            sleepTimerManager.setAudioHandler(audioHandler);
            return sleepTimerManager;
          },
        ),
      ],
      child: MyApp(audioHandler: audioHandler),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AudioHandler audioHandler;

  const MyApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      title: 'Enhanced Music Player',
      theme: themeManager.lightTheme,
      darkTheme: themeManager.darkTheme,
      themeMode: themeManager.getThemeMode(),
      home: const EnhancedMusicPlayerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}