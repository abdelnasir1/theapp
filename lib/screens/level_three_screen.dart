// screens/content/level_three_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';

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
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () {
                    if (!canAccess) {
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
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Thumbnail
                        if (video.thumbnailUrl != null &&
                            video.thumbnailUrl!.isNotEmpty)
                          Image.network(
                            video.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: const Icon(Icons.broken_image_outlined,
                                  size: 50, color: Colors.grey),
                            ),
                          )
                        else
                          Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.image_outlined,
                                size: 50, color: Colors.grey),
                          ),
                        // Play/Lock Overlay
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              canAccess
                                  ? Icons.play_arrow_rounded
                                  : Icons.lock_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Premium Badge
                        if (video.isPremium)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.workspace_premium_rounded,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'مدفوع',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final bool isAuthenticated = authProvider.user != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAuthenticated ? 'محتوى مدفوع' : 'تسجيل الدخول مطلوب',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isAuthenticated
              ? 'هذا المثال ضمن المحتوى المدفوع قم بالترقية لمشاهدته'
              : 'لمشاهدة الدروس المدفوعة يجب عليك تسجيل الدخول أولاً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (isAuthenticated) {
                Navigator.pushNamed(context, '/payment');
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
            child: Text(isAuthenticated ? 'ترقية' : 'تسجيل الدخول'),
          ),
        ],
      ),
    );
  }
}
