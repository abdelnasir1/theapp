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
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().fetchLevelTwoCategories(widget.categoryId);
    });
  }

  List<dynamic> _filterCategories(List<dynamic> categories) {
    var filtered = categories;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((category) {
        return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply sorting
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الباب'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن باب ',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Content
          Expanded(
            child: Consumer<ContentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = _filterCategories(
                  provider.levelTwoCategories
                        .where((c) =>
                        c.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                        .toList()
                      ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0)),
                );

                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text( 'لا يوجد باب بهذا الإسم "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _isGridView ? _buildGridView(categories) : _buildListView(categories);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<dynamic> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category,index);
      },
    );
  }

  Widget _buildListView(List<dynamic> categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCategoryListItem(category,index),
        );
      },
    );
  }

  Widget _buildCategoryCard(dynamic category, int index) {
    return Card(
      elevation: 4,
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
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Category Image or Icon
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(index),
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            // Category Info
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryListItem(dynamic category ,int index) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(index),
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
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
      ),
    );
  }

  IconData _getCategoryIcon(int index) {
    return _categoryIcons[index % _categoryIcons.length];
  }
}

 const List<IconData> _categoryIcons = [
  Icons.show_chart,
  Icons.functions,
  Icons.assessment,
  Icons.compare_arrows,
  Icons.transform,
  Icons.timeline,
  Icons.superscript,
  Icons.trending_down,
  Icons.grid_on,
  Icons.calculate,
  Icons.architecture,
  Icons.category,
  Icons.bar_chart,
  Icons.pie_chart,
  Icons.trending_up,
  Icons.arrow_forward,
  Icons.menu_book,
  Icons.auto_awesome,
  Icons.science,
  Icons.psychology,
];