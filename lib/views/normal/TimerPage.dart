import 'package:flutter/material.dart';
import 'dart:async';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  int _start =
      150; // Durée de l'entraînement en secondes (2 minutes et 30 secondes)
  bool _isActive = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(() {
        if (_start < 1) {
          timer.cancel();
        } else {
          _start--;
        }
      }),
    );
    setState(() {
      _isActive = true;
    });
  }

  void pauseTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _isActive = false;
      });
    }
  }

  void resetTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _start = 150; // Réinitialiser la durée
      _isActive = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entraînement'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Durée : ${_start ~/ 60}:${(_start % 60).toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _isActive ? null : () => startTimer(),
                  tooltip: 'Démarrer',
                  child: const Icon(Icons.play_arrow),
                ),
                FloatingActionButton(
                  onPressed: _isActive ? () => pauseTimer() : null,
                  tooltip: 'Pause',
                  child: const Icon(Icons.pause),
                ),
                FloatingActionButton(
                  onPressed: () => resetTimer(),
                  tooltip: 'Redémarrer',
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
