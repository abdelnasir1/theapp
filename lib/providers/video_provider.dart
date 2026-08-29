import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/content_model.dart';

class VideoCacheManager {
  static const int maxVideos = 40;
  static const String videoDirName = 'LocalCach';

  Future<Video?> featchvideopublic(videoId) async{
    final data = await  Supabase.instance.client
        .from('videos')
        .select('is_premium,plan_type')
        .eq('id',videoId)
        .maybeSingle();
    return Video.fromJson(data!);
  }

  Future<Video?> fetchvideourl(videoId) async{
    final data = await  Supabase.instance.client
        .from('videos')
        .select('video_url')
        .eq('id',videoId)
        .maybeSingle();
    return Video.fromJson(data!);


  }
  Future<Directory> getVideoDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final videoDir = Directory('${appDir.path}/$videoDirName');
    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }
    return videoDir;
  }

  // Get all video files sorted by last modified (oldest first)
  Future<List<File>> getSortedVideos() async {
    final dir = await getVideoDirectory();
    final files = await dir.list().where((entity) => entity is File).cast<File>().toList();

    // Sort by last modified date (oldest first)
    files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
    return files;
  }

  // Enforce limit + LRU
  Future<void> enforceLimit() async {
    final videos = await getSortedVideos();
    if (videos.length <= maxVideos) return;

    final toDelete = videos.sublist(0, videos.length - maxVideos); // Oldest ones
    for (var file in toDelete) {
      await file.delete();
      debugPrint('Deleted old video: ${file.path}');
    }
  }
  String getPathFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf('videos'); // your bucket name
    if (bucketIndex == -1 || bucketIndex + 1 >= segments.length) {
      throw Exception('Invalid Supabase storage URL');
    }

    late final path = segments.sublist(bucketIndex + 1).join('/');
    return path;
  }
  Future<File?> downloadVideo(String supabasePath, String localFileName) async {
    try {
      await enforceLimit();
      var videopath = getPathFromUrl(supabasePath);
      final response = await  Supabase.instance.client.storage
          .from('videos')
          .download(videopath);

      final dir = await getVideoDirectory();
      final file = File('${dir.path}/$localFileName');
      await file.writeAsBytes(response);

      debugPrint('Saved: ${file.path}');
      return file;
    } catch (e) {
      return null;
    }
  }

  // Get local file path if exists
  Future<File?> getLocalVideo(String fileName) async {
    final dir = await getVideoDirectory();
    final file = File('${dir.path}/$fileName');
    return await file.exists() ? file : null;
  }

  // Optional: Delete single video
  Future<void> deleteVideo(String fileName) async {
    final dir = await getVideoDirectory();
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) await file.delete();
  }
}
