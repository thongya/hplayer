import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:intl/intl.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:io' show Platform;
import 'package:equalizer_flutter/equalizer_flutter.dart';

class PlayerScreen extends StatefulWidget {
  final List<SongModel> songs;
  final int initialIndex;

  const PlayerScreen({
    super.key,
    required this.songs,
    required this.initialIndex,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  late ConcatenatingAudioSource _playlist;
  int currentIndex = 0;
  bool isPlaying = false;
  LoopMode loopMode = LoopMode.off;
  bool shuffleModeEnabled = false;
  DateTime? sleepTimerEndTime;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initPlaylist();
    _player.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
    _player.sequenceStateStream.listen((state) {
      setState(() {
        currentIndex = state.currentIndex!;
      });
    });
    _player.loopModeStream.listen((mode) {
      setState(() {
        loopMode = mode;
      });
    });
    _player.shuffleModeEnabledStream.listen((enabled) {
      setState(() {
        shuffleModeEnabled = enabled;
      });
    });
  }

  Future<void> _initPlaylist() async {
    _playlist = ConcatenatingAudioSource(
      children: widget.songs.map((song) {
        return AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: song.id.toString(),
            title: song.displayNameWOExt,
            artist: song.artist ?? "<Unknown>",
            artUri: Uri.parse(
              'content://media/external/audio/media/${song.id}/albumart',
            ),
          ),
        );
      }).toList(),
    );
    await _player.setAudioSource(_playlist, initialIndex: widget.initialIndex);
    _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _toggleLoopMode() {
    final nextMode =
        LoopMode.values[(loopMode.index + 1) % LoopMode.values.length];
    _player.setLoopMode(nextMode);
  }

  void _toggleShuffleMode() {
    _player.setShuffleModeEnabled(!shuffleModeEnabled);
  }

  void _setSleepTimer(BuildContext context) {
    int selectedMinutes = 15;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Set Sleep Timer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current: ${sleepTimerEndTime != null ? "Active" : "Off"}',
                ),
                const SizedBox(height: 20),
                Text('${selectedMinutes} minutes'),
                Slider(
                  min: 5,
                  max: 120,
                  divisions: 23,
                  value: selectedMinutes.toDouble(),
                  onChanged: (value) {
                    setState(() => selectedMinutes = value.round());
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              if (sleepTimerEndTime != null)
                TextButton(
                  onPressed: () {
                    this.setState(() => sleepTimerEndTime = null);
                    _positionSubscription?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel Timer'),
                ),
              TextButton(
                onPressed: () {
                  final endTime = DateTime.now().add(
                    Duration(minutes: selectedMinutes),
                  );
                  this.setState(() => sleepTimerEndTime = endTime);

                  _positionSubscription?.cancel();
                  _positionSubscription =
                      Stream.periodic(const Duration(seconds: 1)).listen((_) {
                        if (DateTime.now().isAfter(endTime)) {
                          _player.pause();
                          this.setState(() => sleepTimerEndTime = null);
                          _positionSubscription?.cancel();
                        }
                      });

                  Navigator.pop(context);
                },
                child: const Text('Set Timer'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEqualizer(BuildContext context) async {
    if (!Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equalizer is only available on Android')),
      );
      return;
    }

    try {
      final sessionId = await _player.androidAudioSessionId;
      if (sessionId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equalizer not available on this device'),
          ),
        );
        return;
      }

      // Initialize the equalizer with the audio session ID
      await EqualizerFlutter.open(sessionId);
      await EqualizerFlutter.setEnabled(true);
      await Future.delayed(const Duration(milliseconds: 100));

      // Get band information
      final centerFrequencies = await EqualizerFlutter.getCenterBandFreqs();
      final bandLevelRange = await EqualizerFlutter.getBandLevelRange();
      if (centerFrequencies.isEmpty ||
          bandLevelRange == null ||
          bandLevelRange.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No equalizer bands available')),
        );
        await EqualizerFlutter.release();
        return;
      }

      final minGain = bandLevelRange[0].toDouble();
      final maxGain = bandLevelRange[1].toDouble();
      final bandLevels = <double>[];
      for (int i = 0; i < centerFrequencies.length; i++) {
        final level = await EqualizerFlutter.getBandLevel(i);
        bandLevels.add(level?.toDouble() ?? 0.0);
      }

      // Get current preset index and map to name
      /*List<String> presetNames = [
        'Normal',
        'Classical',
        'Dance',
        'Flat',
        'Folk',
        'Heavy Metal',
        'Hip Hop',
        'Jazz',
        'Pop',
        'Rock'
      ];

      String currentPreset = 'Normal';
      int currentPresetIndex = await EqualizerFlutter.getCurrentPreset();
      String currentPreset = (currentPresetIndex >= 0 && currentPresetIndex < presetNames.length)
          ? presetNames[currentPresetIndex]
          : 'Custom';*/
      /*List<String> presetNames = [
        'Normal',
        'Classical',
        'Dance',
        'Flat',
        'Folk',
        'Heavy Metal',
        'Hip Hop',
        'Jazz',
        'Pop',
        'Rock'
      ];

// Assume "Normal" (index 0) is default unless user changes
      String currentPreset = 'Normal';*/ // This will be updated when user selects a preset

      List<String> presetNames = await EqualizerFlutter.getPresetNames();
      if (presetNames.isEmpty) {
        presetNames = [
          'Normal',
          'Classical',
          'Dance',
          'Flat',
          'Folk',
          'Heavy Metal',
          'Hip Hop',
          'Jazz',
          'Pop',
          'Rock',
        ];
      }
      String currentPreset = presetNames[0]; // Assume first is active

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Equalizer'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Presets:'),
                      DropdownButton<String>(
                        value: currentPreset,
                        items: presetNames
                            .map(
                              (preset) => DropdownMenuItem(
                                value: preset,
                                child: Text(preset),
                              ),
                            )
                            .toList(),
                        /*onChanged: (value) async {
                          if (value != null && value != 'Custom') {
                            try {
                              final presetIndex = presetNames.indexOf(value);
                              await EqualizerFlutter.setPreset(presetIndex.toString());
                              // Update band levels after preset change
                              for (int i = 0; i < centerFrequencies.length; i++) {
                                final level = await EqualizerFlutter.getBandLevel(i);
                                bandLevels[i] = level?.toDouble() ?? 0.0;
                              }
                              setDialogState(() {
                                currentPreset = value;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to set preset: $e')),
                              );
                            }
                          }
                        },*/
                        onChanged: (value) async {
                          if (value != null) {
                            try {
                              final presetIndex = presetNames.indexOf(value);
                              await EqualizerFlutter.setPreset(
                                presetIndex.toString(),
                              );

                              // Update band levels after preset change
                              for (
                                int i = 0;
                                i < centerFrequencies.length;
                                i++
                              ) {
                                final level =
                                    await EqualizerFlutter.getBandLevel(i);
                                bandLevels[i] = level?.toDouble() ?? 0.0;
                              }

                              // Only update UI state *after* success
                              setDialogState(() {
                                currentPreset =
                                    value; // Track selected preset manually
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to set preset: $e'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: centerFrequencies.length,
                      itemBuilder: (context, index) {
                        final frequency = centerFrequencies[index];
                        final gain = bandLevels[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              Text('${(frequency ~/ 1000)} kHz'),
                              Row(
                                children: [
                                  Text('${minGain.toInt()} dB'),
                                  Expanded(
                                    child: Slider(
                                      min: minGain,
                                      max: maxGain,
                                      value: gain,
                                      onChanged: (value) async {
                                        await EqualizerFlutter.setBandLevel(
                                          index,
                                          value.round(),
                                        );
                                        setDialogState(() {
                                          bandLevels[index] = value;
                                          currentPreset = 'Custom';
                                        });
                                      },
                                    ),
                                  ),
                                  Text('${maxGain.toInt()} dB'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await EqualizerFlutter.release();
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Equalizer error: $e')));
      await EqualizerFlutter.release();
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.songs[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: Icon(
              loopMode == LoopMode.off
                  ? Icons.repeat
                  : loopMode == LoopMode.one
                  ? Icons.repeat_one
                  : Icons.repeat,
              color: loopMode != LoopMode.off
                  ? Theme.of(context).hintColor
                  : null,
            ),
            onPressed: _toggleLoopMode,
          ),
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: shuffleModeEnabled ? Theme.of(context).hintColor : null,
            ),
            onPressed: _toggleShuffleMode,
          ),
          IconButton(
            icon: Icon(
              Icons.timer,
              color: sleepTimerEndTime != null
                  ? Theme.of(context).hintColor
                  : null,
            ),
            onPressed: () => _setSleepTimer(context),
          ),
          IconButton(
            icon: const Icon(Icons.equalizer),
            onPressed: () => _showEqualizer(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              size: 300,
              nullArtworkWidget: const Icon(Icons.music_note, size: 300),
            ),
            const SizedBox(height: 20),
            Text(
              song.displayNameWOExt,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              song.artist ?? "<Unknown>",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: () => _player.seekToPrevious(),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 64,
                  onPressed: () => isPlaying ? _player.pause() : _player.play(),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: () => _player.seekToNext(),
                ),
              ],
            ),
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _player.duration ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      min: 0.0,
                      max: duration.inMilliseconds.toDouble(),
                      value: position.inMilliseconds.toDouble().clamp(
                        0.0,
                        duration.inMilliseconds.toDouble(),
                      ),
                      onChanged: (value) {
                        _player.seek(Duration(milliseconds: value.round()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position)),
                          Text(_formatDuration(duration)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            if (sleepTimerEndTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Sleep timer: ${DateFormat('HH:mm').format(sleepTimerEndTime!)}',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
