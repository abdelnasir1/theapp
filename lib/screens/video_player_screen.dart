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
  final VideoCacheManager manager = VideoCacheManager();
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _showIcon = false;
  Timer? _hideTimer;
  bool _isPlaying = false;

  Future<void> _initVideo() async {
    try {
      File? file = await manager.getLocalVideo(widget.videoId);
      file ??= await manager.downloadVideo(widget.videoUrl, widget.videoId);

      if (file == null || !mounted) return;

      final controller = VideoPlayerController.file(file);
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      controller.addListener(() {
        if (!mounted) return;
        setState(() => _isPlaying = controller.value.isPlaying);
      });

      setState(() {
        _controller = controller;
        _isReady = true;
        _isPlaying = controller.value.isPlaying;
      });
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initVideo());
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();          // safe now
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: Center(
          child: _isReady && _controller != null
              ? Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
              AnimatedOpacity(
                opacity: _showIcon ? 1 : 0,
                duration: const Duration(milliseconds: 100),
                child: IgnorePointer(
                  child: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 72,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

