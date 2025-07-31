import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Appearance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeService.isDarkMode,
                onChanged: (value) => themeService.toggleTheme(),
              ),
              ListTile(
                title: const Text('Primary Color'),
                trailing: Container(
                  width: 24,
                  height: 24,
                  color: themeService.primaryColor,
                ),
                onTap: () => _showColorPicker(
                  context,
                  'Primary Color',
                  themeService.primaryColor,
                      (color) => themeService.setPrimaryColor(color),
                ),
              ),
              ListTile(
                title: const Text('Accent Color'),
                trailing: Container(
                  width: 24,
                  height: 24,
                  color: themeService.accentColor,
                ),
                onTap: () => _showColorPicker(
                  context,
                  'Accent Color',
                  themeService.accentColor,
                      (color) => themeService.setAccentColor(color),
                ),
              ),
              const Divider(),
              const Text(
                'About',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showColorPicker(
      BuildContext context,
      String title,
      Color currentColor,
      Function(Color) onColorChanged,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}