// screens/content/level_three_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/subscription_provider.dart';

class LevelThreeScreen extends StatefulWidget {
  final String categoryId;

  const LevelThreeScreen({super.key, required this.categoryId});

  @override
  State<LevelThreeScreen> createState() => _LevelThreeScreenState();
}

class _LevelThreeScreenState extends State<LevelThreeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchVideos(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أمثلة الباب'),
      ),
      body: Consumer2<ContentProvider, SubscriptionProvider>(
        builder: (context, contentProvider, subscriptionProvider, _) {
          if (contentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contentProvider.videos.length,
            itemBuilder: (context, index) {
              final video = contentProvider.videos[index];
              final canAccess = subscriptionProvider.canAccessContent(
                video.isPremium,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.play_circle, size: 30),
                      ),
                      if (video.isPremium)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'مدفوع',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    video.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: canAccess
                      ? const Icon(Icons.play_arrow)
                      : const Icon(Icons.lock),
                  onTap: () {
                    if (!canAccess) {
                      // Show subscription prompt
                      _showSubscriptionDialog(context);
                    } else {
                      Navigator.pushNamed(
                        context,
                        '/video-player',
                        arguments: {
                          'videoId': video.id,
                          'videoUrl': video.videoUrl,
                        },
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('محتوى مدفوع'),
        content: const Text(
          'هذا المثال ضمن المحتوى المدفوع قم بالترقية لمشاهدته'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/payment');
            },
            child: const Text('ترقية'),
          ),
        ],
      ),
    );
  }
}
