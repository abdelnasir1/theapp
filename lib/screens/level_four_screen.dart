import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/favorites_provider.dart';

class LevelFourScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const LevelFourScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<LevelFourScreen> createState() => _LevelFourScreenState();
}

class _LevelFourScreenState extends State<LevelFourScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchExamples(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Harmonic Header
          _buildHeader(context),

          // Content List
          Expanded(
            child: Consumer3<ContentProvider, SubscriptionProvider,
                FavoritesProvider>(
              builder: (context, contentProvider, subscriptionProvider,
                  favoritesProvider, _) {
                if (contentProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (contentProvider.examples.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_late_rounded,
                            size: 80,
                            color: colorScheme.primary.withValues(alpha: 0.1)),
                        const SizedBox(height: 16),
                        const Text('لا توجد تمارين في هذا الدرس',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: contentProvider.examples.length,
                  itemBuilder: (context, index) {
                    final example = contentProvider.examples[index];
                    final isFav = favoritesProvider.isFavorite(example.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/example-page',
                            arguments: {
                              'examples': contentProvider.examples,
                              'index': index,
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seamless Blended Thumbnail
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    example.thumbnail,
                                    width: double.infinity,
                                    fit: BoxFit.fitWidth,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: colorScheme.surfaceContainerLow,
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: colorScheme.surfaceContainerLow,
                                      child: Icon(Icons.broken_image_rounded,
                                          size: 50, color: colorScheme.primary),
                                    ),
                                  ),
                                ),
                                // Favorite Button Overlay
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isFav
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: isFav ? Colors.red : Colors.white,
                                        size: 22,
                                      ),
                                      onPressed: () => favoritesProvider
                                          .toggleFavorite(example),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Removed the exercise name/title below the image as requested
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Branded Tailer
          _buildTailer(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String headerPath = 'assets/headers/${widget.categoryName}.jpg';
    const String defaultHeader = 'assets/images/Slide1_cluster_2.webp';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 10),
            child: Image.asset(
              headerPath,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                defaultHeader,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTailer(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colorScheme = Theme.of(context).colorScheme;
    final String footerPath = 'assets/footers/${widget.categoryName}.jpg';
    const String defaultFooter = 'assets/images/Slide1_cluster_4.webp';

    return Container(
      width: double.infinity,
      color: colorScheme.surface,
      child: Column(
        children: [
          Image.asset(
            footerPath,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              defaultFooter,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: bottomPadding + 8)
        ],
      ),
    );
  }
}
