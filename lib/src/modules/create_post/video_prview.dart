import 'dart:io';
import 'package:flutter/material.dart';
import 'package:studytogether_v1/src/modules/create_post/full_screen_video.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPreview extends StatefulWidget {
  final dynamic videoUrl;

  const VideoPreview({super.key, required this.videoUrl});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    // ignore: deprecated_member_use
    if (widget.videoUrl is File) {
      _controller = VideoPlayerController.file(widget.videoUrl);
    } else if (widget.videoUrl is String) {
      // ignore: deprecated_member_use
      _controller = VideoPlayerController.network(widget.videoUrl);
    } else {
      throw ArgumentError("videoSource must be a File or a String URL");
    }
    _controller
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused ||
  //       state == AppLifecycleState.inactive) {
  //     _controller.pause();
  //   }
  // }

  @override
  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction < 0.5 && _controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? VisibilityDetector(
          key: Key("video_${widget.videoUrl}"),
          onVisibilityChanged: _handleVisibilityChanged,
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                if (!_controller.value.isPlaying)
                  Icon(Icons.play_arrow, color: Colors.white, size: 40),

                Positioned(
                  bottom: 0,
                  right: 15,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => FullScreenVideo(controller: _controller),
                        ),
                      );
                    },
                    icon: Icon(Icons.fullscreen, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
        )
        : Container(
          width: 100,
          color: Colors.black12,
          child: Center(child: CircularProgressIndicator()),
        );
  }
}
