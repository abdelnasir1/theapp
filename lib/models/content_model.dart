// models/content_model.dart
class Category {
  final String id;
  final String name;
  final String? description;
  final int level;
  final String? parentId;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.level,
    this.parentId,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      level: json['level'] ?? 1,
      parentId: json['parent_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level,
      'parent_id': parentId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class Video {
  final String id;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int duration;
  final String categoryId;
  final bool isPremium;
  final DateTime? createdAt;

  Video({
    required this.id,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    this.duration = 30,
    required this.categoryId,
    this.isPremium = true,
    this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      duration: json['duration'] ?? 30,
      categoryId: json['category_id'] ?? '',
      isPremium: json['is_premium'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'category_id': categoryId,
      'is_premium': isPremium,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}