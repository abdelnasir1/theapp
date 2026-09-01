import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/constants.dart';

class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, VideoModel> _videoCache = {};

  Future<VideoModel?> featchvideopublic(String? videoId) async {
    if (videoId == null) return null;
    if (_videoCache.containsKey(videoId)) return _videoCache[videoId];

    try {
      final data = await _supabase
          .from('videos')
          .select()
          .eq('id', videoId)
          .single();

      final video = VideoModel.fromJson(data);
      _videoCache[videoId] = video;
      return video;
    } catch (e) {
      debugPrint('Error fetching video: $e');
      return null;
    }
  }

  Future<VideoUrlModel?> fetchvideourl(String videoId) async {
    try {
      final data = await _supabase
          .from('videos')
          .select()
          .eq('id', videoId)
          .single();

      return VideoUrlModel.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching video URL: $e');
      return null;
    }
  }

  // --- LOCAL CACHING LOGIC ---

  Future<File?> getLocalVideo(String videoId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/video_$videoId.mp4');
      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      debugPrint('Error accessing local video: $e');
    }
    return null;
  }

  Future<File?> downloadVideo(String url, String videoId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/video_$videoId.mp4');

      // Simple limit check from constants if available
      final int limit = AppConstants.localVideosLimit;
      final existingFiles = directory.listSync().where((f) => f.path.contains('video_')).toList();
      
      if (existingFiles.length >= limit) {
         // Optionally delete oldest if limit reached, or just stop
         debugPrint('Cache limit reached, skipping download');
         return null;
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      debugPrint('Error downloading video: $e');
    }
    return null;
  }
}

class VideoModel {
  final String id;
  final bool isPremium;
  final String? planType;

  VideoModel({
    required this.id,
    required this.isPremium,
    this.planType,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? '',
      isPremium: json['is_premium'] ?? false,
      planType: json['plan_type'],
    );
  }
}

class VideoUrlModel {
  final String videoId;
  final String videoUrl;

  VideoUrlModel({
    required this.videoId,
    required this.videoUrl,
  });

  factory VideoUrlModel.fromJson(Map<String, dynamic> json) {
    return VideoUrlModel(
      videoId: json['id'] ?? '',
      videoUrl: json['video_url'] ?? '',
    );
  }
}
