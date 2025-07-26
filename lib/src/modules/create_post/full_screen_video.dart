import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideo extends StatefulWidget {
  final VideoPlayerController controller;
  const FullScreenVideo({super.key, required this.controller});

  @override
  State<FullScreenVideo> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<FullScreenVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    if (!_controller.value.isPlaying) {
      _controller.play();
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),

          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
