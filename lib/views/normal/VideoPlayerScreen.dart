import 'dart:async';

import 'package:flutter/material.dart';
import 'package:testapp/views/normal/Exrcice.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  late final Exercise exercise;

  VideoPlayerScreen({required this.exercise});
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  Timer? _timer;
  int _start = 150; // Duration in seconds (e.g., 2 minutes and 30 seconds)
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.exercise.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

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
      _start = 150; // Reset duration
      _isActive = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _controller.value.isInitialized
                  ? VideoPlayer(_controller)
                  : Center(child: CircularProgressIndicator()),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.exercise.description,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Durée : ${_start ~/ 60}:${(_start % 60).toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FloatingActionButton(
                        onPressed: _isActive ? null : startTimer,
                        tooltip: 'Démarrer',
                        child: Icon(Icons.play_arrow),
                      ),
                      FloatingActionButton(
                        onPressed: _isActive ? pauseTimer : null,
                        tooltip: 'Pause',
                        child: Icon(Icons.pause),
                      ),
                      FloatingActionButton(
                        onPressed: resetTimer,
                        tooltip: 'Redémarrer',
                        child: Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
