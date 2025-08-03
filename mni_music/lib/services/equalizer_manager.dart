// equalizer_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EqualizerManager with ChangeNotifier {
  static const String PREF_EQ_ENABLED = 'eq_enabled';
  static const String PREF_EQ_PRESET = 'eq_preset';
  static const String PREF_EQ_BANDS = 'eq_bands';

  bool _isEnabled = false;
  String _currentPreset = 'Flat';
  Map<int, double> _bandGains = {
    60: 0.0,    // 60 Hz
    170: 0.0,   // 170 Hz
    310: 0.0,   // 310 Hz
    600: 0.0,   // 600 Hz
    1000: 0.0,  // 1 kHz
    3000: 0.0,  // 3 kHz
    6000: 0.0,  // 6 kHz
    12000: 0.0, // 12 kHz
    14000: 0.0, // 14 kHz
    16000: 0.0, // 16 kHz
  };

  static const List<String> presets = [
    'Flat',
    'Pop',
    'Rock',
    'Jazz',
    'Classical',
    'Bass Boost',
    'Treble Boost',
  ];

  static const Map<String, Map<int, double>> presetValues = {
    'Flat': {
      60: 0.0, 170: 0.0, 310: 0.0, 600: 0.0, 1000: 0.0,
      3000: 0.0, 6000: 0.0, 12000: 0.0, 14000: 0.0, 16000: 0.0
    },
    'Pop': {
      60: 2.0, 170: 1.0, 310: 0.0, 600: 0.0, 1000: 0.0,
      3000: 0.0, 6000: 1.0, 12000: 2.0, 14000: 2.5, 16000: 3.0
    },
    'Rock': {
      60: 4.0, 170: 2.0, 310: 0.0, 600: 0.0, 1000: 0.0,
      3000: 1.0, 6000: 2.0, 12000: 3.0, 14000: 3.5, 16000: 4.0
    },
    'Jazz': {
      60: 2.0, 170: 1.0, 310: 0.0, 600: 0.0, 1000: 0.0,
      3000: 1.0, 6000: 1.0, 12000: 2.0, 14000: 2.5, 16000: 3.0
    },
    'Classical': {
      60: -2.0, 170: -1.0, 310: 0.0, 600: 0.0, 1000: 0.0,
      3000: 1.0, 6000: 2.0, 12000: 3.0, 14000: 3.5, 16000: 4.0
    },
    'Bass Boost': {
      60: 5.0, 170: 4.0, 310: 3.0, 600: 2.0, 1000: 1.0,
      3000: 0.0, 6000: 0.0, 12000: 0.0, 14000: 0.0, 16000: 0.0
    },
    'Treble Boost': {
      60: 0.0, 170: 0.0, 310: 0.0, 600: 0.0, 1000: 0.0,
      3000: 2.0, 6000: 3.0, 12000: 4.0, 14000: 5.0, 16000: 6.0
    },
  };

  bool get isEnabled => _isEnabled;
  String get currentPreset => _currentPreset;
  Map<int, double> get bandGains => _bandGains;

  EqualizerManager() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isEnabled = prefs.getBool(PREF_EQ_ENABLED) ?? false;
    _currentPreset = prefs.getString(PREF_EQ_PRESET) ?? 'Flat';

    // Load band gains
    final savedBands = prefs.getString(PREF_EQ_BANDS);
    if (savedBands != null) {
      final bandsMap = Map<String, dynamic>.from(
          savedBands.split(',').asMap().map((i, pair) {
            final parts = pair.split(':');
            return MapEntry(i, '${parts[0]}:${parts[1]}');
          })
      );

      _bandGains = {};
      bandsMap.values.forEach((pair) {
        final parts = (pair as String).split(':');
        _bandGains[int.parse(parts[0])] = double.parse(parts[1]);
      });
    }

    notifyListeners();
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PREF_EQ_ENABLED, _isEnabled);
    await prefs.setString(PREF_EQ_PRESET, _currentPreset);

    final bandsString = _bandGains.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    await prefs.setString(PREF_EQ_BANDS, bandsString);
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    saveSettings();
    notifyListeners();
  }

  void setPreset(String preset) {
    _currentPreset = preset;
    if (presetValues.containsKey(preset)) {
      _bandGains = Map.from(presetValues[preset]!);
    }
    saveSettings();
    notifyListeners();
  }

  void setBandGain(int frequency, double gain) {
    _bandGains[frequency] = gain;
    _currentPreset = 'Custom';
    saveSettings();
    notifyListeners();
  }

  double getBandGain(int frequency) {
    return _bandGains[frequency] ?? 0.0;
  }
}