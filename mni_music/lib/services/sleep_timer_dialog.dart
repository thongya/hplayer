import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sleep_timer_manager.dart';

class SleepTimerDialog extends StatefulWidget {
  const SleepTimerDialog({super.key});

  @override
  State<SleepTimerDialog> createState() => _SleepTimerDialogState();
}

class _SleepTimerDialogState extends State<SleepTimerDialog> {
  int _selectedMinutes = 15;
  final List<int> _presetMinutes = [5, 15, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    final sleepTimerManager = Provider.of<SleepTimerManager>(context);

    return AlertDialog(
      title: const Text('Sleep Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sleepTimerManager.isActive) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Time remaining:'),
                Text(
                  _formatDuration(sleepTimerManager.timeLeft),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: sleepTimerManager.timeLeft.inSeconds >
                  sleepTimerManager.timeLeft.inSeconds
                  ? 1.0
                  : sleepTimerManager.timeLeft.inSeconds /
                  (sleepTimerManager.timeLeft.inSeconds +
                      (sleepTimerManager.timeLeft.inSeconds -
                          sleepTimerManager.timeLeft.inSeconds)),
            ),
            const SizedBox(height: 16),
          ],
          const Text('Set timer for:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetMinutes.map((minutes) {
              return ChoiceChip(
                label: Text('${minutes}m'),
                selected: _selectedMinutes == minutes,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedMinutes = minutes;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Custom:'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _selectedMinutes.toDouble(),
                  min: 1,
                  max: 240,
                  divisions: 239,
                  label: '${_selectedMinutes}m',
                  onChanged: (value) {
                    setState(() {
                      _selectedMinutes = value.toInt();
                    });
                  },
                ),
              ),
              Text('${_selectedMinutes}m'),
            ],
          ),
        ],
      ),
      actions: [
        if (sleepTimerManager.isActive)
          TextButton(
            onPressed: () {
              sleepTimerManager.cancelTimer();
              Navigator.pop(context);
            },
            child: const Text('Cancel Timer'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            sleepTimerManager.startTimer(
              Duration(minutes: _selectedMinutes),
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Sleep timer set for $_selectedMinutes minutes',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Set Timer'),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
    } else {
      return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
    }
  }
}