class Mix {
  final String id;
  final String title;
  final String tag;
  final String tagColor;
  final String subtitle;
  final String cover;
  final String badge;

  const Mix({
    required this.id,
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.subtitle,
    required this.cover,
    required this.badge,
  });

  factory Mix.fromJson(Map<String, dynamic> json) {
    return Mix(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      tagColor: json['tagColor'] as String? ?? '#E91E63',
      subtitle: json['subtitle'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
    );
  }
}

class QuickMix {
  final String title;
  final String subtitle;
  final String cover;

  const QuickMix({
    required this.title,
    required this.subtitle,
    required this.cover,
  });

  factory QuickMix.fromJson(Map<String, dynamic> json) {
    return QuickMix(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
    );
  }
}
