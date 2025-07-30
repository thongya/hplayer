import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final themeService = ThemeService(prefs);

  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Music Player',
          theme: themeService.getTheme(),
          home: FutureBuilder(
            future: _checkPermissions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const HomeScreen();
              }
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          ),
        );
      },
    );
  }

  Future<void> _checkPermissions() async {
    await Permission.storage.request();
    await Permission.audio.request();
  }
}