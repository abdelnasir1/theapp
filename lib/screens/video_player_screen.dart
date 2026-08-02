// screens/content/video_player_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
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
  
  late final Player _player = Player();
  late final VideoController _controller = VideoController(_player);

  bool _isReady = false;
  bool _showIcon = false;
  Timer? _hideTimer;
  bool _isPlaying = false;

  Future<void> _initVideo() async {
    try {
      File? file = await manager.getLocalVideo(widget.videoId);
      file ??= await manager.downloadVideo(widget.videoUrl, widget.videoId);

      if (file == null || !mounted) return;

      final String path = Platform.isWindows ? file.path : 'file://${file.path}';
      await _player.open(Media(path));
      await _player.play();

      if (!mounted) return;

      _player.stream.playing.listen((playing) {
        if (!mounted) return;
        setState(() => _isPlaying = playing);
      });

      setState(() {
        _isReady = true;
      });
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (!_isReady) return;
    await _player.playOrPause();

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
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Transparent AppBar for the back button
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
          child: _isReady
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Video(controller: _controller),
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
              : const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
