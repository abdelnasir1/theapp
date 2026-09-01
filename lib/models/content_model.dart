class Category {
  final String id;
  final String name;
  final int level;
  final String? parentId;
  final int? index;

  Category({
    required this.id,
    required this.name,
    required this.level,
    this.parentId,
    this.index
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? 1,
      parentId: json['parent_id'],
      index: json['index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'parent_id': parentId,
      'index': index,
    };
  }
}

class Solution {
  final String label;
  final bool isCorrect;

  const Solution({
    required this.label,
    required this.isCorrect,
  });

  factory Solution.fromJson(Map<String, dynamic> json) {
    return Solution(
      label: json['label'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'is_correct': isCorrect,
    };
  }
}

class Video {
  final String id;
  final String videoUrl;
  final bool isPremium;
  final String? planType;

  Video({
    required this.id,
    required this.videoUrl,
    this.isPremium = true,
    this.planType,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      videoUrl: json['video_url'] ?? '',
      isPremium: json['is_premium'] ?? true,
      planType: json['plan_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_url': videoUrl,
      'is_premium': isPremium,
      'plan_type': planType,
    };
  }
}

class Example {
  final String id;
  final String name;
  final String? parentCategory;
  final String questionImageUrl;
  final String thumbnail;
  final String? videoId;
  final List<Solution> solutions;

  Example({
    required this.id,
    required this.name,
    this.parentCategory,
    required this.questionImageUrl,
    required this.thumbnail,
    this.videoId,
    this.solutions = const [],
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    // Parse com.maazplatform.solutions from the 'options' JSON column
    var solutionsList = <Solution>[];
    if (json['options'] != null) {
      if (json['options'] is List) {
        solutionsList = (json['options'] as List)
            .map((s) => Solution.fromJson(s as Map<String, dynamic>))
            .toList();
      } else if (json['options'] is Map) {
        final Map<String, dynamic> optionsMap = json['options'];
        solutionsList = optionsMap.entries
            .map((e) => Solution(label: e.key, isCorrect: e.value == true))
            .toList();
      }
    }

    return Example(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      parentCategory: json['parent_category'],
      questionImageUrl: json['question_image_url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      videoId: json['video_id'],
      solutions: solutionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_category': parentCategory,
      'question_image_url': questionImageUrl,
      'thumbnail': thumbnail,
      'video_id': videoId,
      'options': solutions.map((s) => s.toJson()).toList(),
    };
  }
}
