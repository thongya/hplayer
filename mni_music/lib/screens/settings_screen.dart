// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../services/equalizer_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final equalizerManager = Provider.of<EqualizerManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Settings
          const ListTile(
            title: Text('Theme'),
            subtitle: Text('Choose app theme'),
          ),
          RadioListTile<String>(
            title: const Text('Light'),
            value: ThemeManager.LIGHT_THEME,
            groupValue: themeManager.currentTheme,
            onChanged: (value) {
              if (value != null) {
                themeManager.setTheme(value);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('Dark'),
            value: ThemeManager.DARK_THEME,
            groupValue: themeManager.currentTheme,
            onChanged: (value) {
              if (value != null) {
                themeManager.setTheme(value);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('System Default'),
            value: ThemeManager.SYSTEM_THEME,
            groupValue: themeManager.currentTheme,
            onChanged: (value) {
              if (value != null) {
                themeManager.setTheme(value);
              }
            },
          ),

          const Divider(),

          // Equalizer Settings
          SwitchListTile(
            title: const Text('Equalizer'),
            subtitle: const Text('Enable audio equalizer'),
            value: equalizerManager.isEnabled,
            onChanged: (value) {
              equalizerManager.setEnabled(value);
            },
          ),

          if (equalizerManager.isEnabled) ...[
            const ListTile(
              title: Text('Preset'),
              subtitle: Text('Choose equalizer preset'),
            ),
            ...EqualizerManager.presets.map((preset) {
              return RadioListTile<String>(
                title: Text(preset),
                value: preset,
                groupValue: equalizerManager.currentPreset,
                onChanged: (value) {
                  if (value != null) {
                    equalizerManager.setPreset(value);
                  }
                },
              );
            }).toList(),

            const ListTile(
              title: Text('Custom Bands'),
            ),
            ...equalizerManager.bandGains.entries.map((entry) {
              return ListTile(
                title: Text('${entry.key} Hz'),
                subtitle: Slider(
                  value: entry.value,
                  min: -10.0,
                  max: 10.0,
                  divisions: 200,
                  label: entry.value.toStringAsFixed(1),
                  onChanged: (value) {
                    equalizerManager.setBandGain(entry.key, value);
                  },
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}