import 'package:flutter/material.dart';
import 'dart:async';
import 'audio_service_handler.dart';

class SleepTimerManager with ChangeNotifier {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  bool _isActive = false;
  AudioServiceHandler? _audioHandler;

  Duration get timeLeft => _timeLeft;
  bool get isActive => _isActive;

  void setAudioHandler(AudioServiceHandler audioHandler) {
    _audioHandler = audioHandler;
  }

  void startTimer(Duration duration) {
    _cancelTimer();
    _timeLeft = duration;
    _isActive = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        _timeLeft = _timeLeft - const Duration(seconds: 1);
        notifyListeners();
      } else {
        _stopMusicAndCancelTimer();
      }
    });

    notifyListeners();
  }

  void cancelTimer() {
    _cancelTimer();
    _isActive = false;
    _timeLeft = Duration.zero;
    notifyListeners();
  }

  void _stopMusicAndCancelTimer() {
    _isActive = false;
    _timeLeft = Duration.zero;
    _cancelTimer();

    // Stop music playback
    _audioHandler?.stopPlayback();

    notifyListeners();
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}