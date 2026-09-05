import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/content_provider.dart';

class LevelThreeScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const LevelThreeScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<LevelThreeScreen> createState() => _LevelThreeScreenState();
}

class _LevelThreeScreenState extends State<LevelThreeScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchLevelThreeCategories(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Column(
        children: [
          // Harmonic Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'أبحث عن درس...',
                prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          Expanded(
            child: Consumer<ContentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = provider.levelThreeCategories
                    .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList()
                  ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

                if (categories.isEmpty) {
                  return const Center(child: Text('لا يوجد دروس'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 80), // Added bottom padding
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/level-four',
                            arguments: {
                              'categoryId': category.id,
                              'categoryName': category.name,
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimaryContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 4, // Thick boarder
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Expanded(
                                child: Text(
                                  category.name,
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: colorScheme.onPrimary,
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
          ),
        ],
      ),
    );
  }
}
