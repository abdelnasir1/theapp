import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/content_provider.dart';

class LevelTwoScreen extends StatefulWidget {
  final String categoryId;

  const LevelTwoScreen({super.key, required this.categoryId});

  @override
  State<LevelTwoScreen> createState() => _LevelTwoScreenState();
}

class _LevelTwoScreenState extends State<LevelTwoScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchLevelTwoCategories(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title:  Text(
          'اختر الباب'
          ,style: TextStyle(
          fontWeight: FontWeight.w700 ,
          color: colorScheme.primary,
        ),
      )),
      body: Column(
        children: [
          // Harmonic Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن باب...',
                prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Content
          Expanded(
            child: Consumer<ContentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = provider.levelTwoCategories
                    .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList()
                  ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

                if (categories.isEmpty) {
                  return const Center(child: Text('لا يوجد نتائج'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/level-three',
                            arguments: {
                              'categoryId': category.id,
                              'categoryName': category.name,
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                            color:colorScheme.onPrimaryContainer ,
                            borderRadius: BorderRadius.circular(16),

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
