import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_provider.dart'; // your VideoCacheManager

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
      // 1. Try local cache first (instant start if already downloaded)
      File? localFile = await manager.getLocalVideo(widget.videoId);

      if (localFile != null && await localFile.exists()) {
        // Already cached → play local file
        await _playFromFile(localFile);
        return;
      }

      // 2. Not cached → play from network immediately
      await _playFromNetwork(widget.videoUrl);

      // 3. Download in the background (don’t await)
      _downloadInBackground();
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  Future<void> _playFromNetwork(String url) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));

    await controller.initialize();
    if (!mounted) {
      controller.dispose();
      return;
    }

    _attachListeners(controller);
    await controller.play();

    setState(() {
      _controller = controller;
      _isReady = true;
      _isPlaying = true;
    });
  }

  Future<void> _playFromFile(File file) async {
    final controller = VideoPlayerController.file(file);

    await controller.initialize();
    if (!mounted) {
      controller.dispose();
      return;
    }

    _attachListeners(controller);
    await controller.play();

    setState(() {
      _controller = controller;
      _isReady = true;
      _isPlaying = true;
    });
  }

  void _attachListeners(VideoPlayerController controller) {
    controller.addListener(() {
      if (!mounted) return;
      final playing = controller.value.isPlaying;
      if (playing != _isPlaying) {
        setState(() => _isPlaying = playing);
      }
    });
  }

  /// Downloads the video without blocking playback
  void _downloadInBackground() {
    // Fire and forget
    manager.downloadVideo(widget.videoUrl, widget.videoId).then((file) {
      if (file != null) {
        debugPrint('Video cached successfully: ${file.path}');
        // Optional: you could switch to the local file here,
        // but it’s usually not necessary while the user is watching.
      }
    }).catchError((e) {
      debugPrint('Background download failed: $e');
    });
  }

  Future<void> _togglePlayPause() async {
    final controller = _controller;
    if (!_isReady || controller == null) return;

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
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: Center(
          child: _isReady && _controller != null
              ? Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
              AnimatedOpacity(
                opacity: _showIcon ? 1.0 : 0.0,
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
              : const CircularProgressIndicator(color: Colors.blue),
        ),
      ),
    );
  }
}