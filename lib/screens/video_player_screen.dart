// screens/content/video_player_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}


class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoCacheManager manager = VideoCacheManager();
  late VideoPlayerController _controller;
  bool _showIcon = false;
  Timer? _hideTimer;
  bool _isPlaying = false;

  Future<void> _initVideo() async {
    try {
      //from storge
      File? file = await manager.getLocalVideo(widget.videoId);

      //download it
      file ??= await manager.downloadVideo(widget.videoUrl, widget.videoId);
      if (file == null) {
        return;
      }
      _controller = VideoPlayerController.file(file)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isPlaying = _controller.value.isPlaying;
            });
          }

        });
      _controller.addListener(() {
        if (!mounted) return;
        setState(() => _isPlaying = _controller.value.isPlaying);
      });
    } catch (e) {
      return ;
    }
  }

  Future<void> _togglePlayPause() async {
    if (!_controller.value.isInitialized) return;

    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }

    setState(() => _showIcon = true);

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _showIcon = false);
    });
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVideo();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
              children: [
              // Your video
              if (_controller.value.isInitialized)
                SizedBox(
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
            else
              const Center(child: CircularProgressIndicator()),

      // Overlay icon for half a second
             AnimatedOpacity(
              opacity: _showIcon ? 1 : 0,
              duration: const Duration(milliseconds: 100),
              child: IgnorePointer(
              child: Icon(
               _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                size: 72,
                color: Colors.white.withOpacity(0.9),
              ),
          ),
        ), ] )
        )
      )
    );
  }
}
