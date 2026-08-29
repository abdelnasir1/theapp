import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/content_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/favorites_provider.dart';
import '../widgets/custom_painter.dart';

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
          // Header (Top Section)
          _buildHeader(context),

          // Main List (Body)
          Expanded(
            child: Stack(
              children: [
                // Background overlay
                Positioned.fill(
                  child: Container(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                  ),
                ),

                Consumer3<ContentProvider, SubscriptionProvider, FavoritesProvider>(
                  builder: (context, contentProvider, subscriptionProvider, favoritesProvider, _) {
                    if (contentProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (contentProvider.examples.isEmpty) {
                      return const Center(child: Text('لا توجد تمارين في هذا الدرس'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: contentProvider.examples.length,
                      itemBuilder: (context, index) {
                        final example = contentProvider.examples[index];
                        final isFav = favoritesProvider.isFavorite(example.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
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
                            child: Stack(
                              children: [
                                // Example Thumbnail (Blends with background)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    example.thumbnail,
                                    width: double.infinity,
                                    fit: BoxFit.fitWidth,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      height: 150,
                                      width: double.infinity,
                                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      child: const Icon(Icons.image_outlined,
                                          size: 50, color: Colors.grey),
                                    ),
                                  ),
                                ),

                                // Favorite Toggle
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        favoritesProvider.toggleFavorite(example);
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isFav
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          color: isFav ? Colors.red : Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Tailer (Bottom Section)
          _buildTailer(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Asset path convention: assets/headers/category_name.png
    final String headerPath = 'assets/headers/${widget.categoryName}.jpg';
    const String defaultHeader = 'assets/images/Slide1_cluster_2.png';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Header Image
          Padding(
            padding: const EdgeInsets.only(top: 40), // Space for status bar
            child: Image.asset(
              headerPath,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  defaultHeader,
                  width: double.infinity,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
          // Floating Back Button
          Positioned(
            top: 50,
            right: 14,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                color: colorScheme.onSurface,
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

    // Asset path convention: assets/footers/category_name.png
    final String footerPath = 'assets/footers/${widget.categoryName}.jpg';
    const String defaultFooter = 'assets/images/Slide1_cluster_4.png';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Column(
        children: [
          Image.asset(
            footerPath,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                defaultFooter,
                width: double.infinity,
                fit: BoxFit.contain,
              );
            },
          ),
          SizedBox(height: bottomPadding)
        ],
      ),
    );
  }
}
