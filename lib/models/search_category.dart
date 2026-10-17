import 'package:flutter/material.dart';

class SearchCategory {
  final String id;
  final String title;
  final Color color;
  final String imageUrl;

  const SearchCategory({
    required this.id,
    required this.title,
    required this.color,
    required this.imageUrl,
  });
}

class StoryItem {
  final String id;
  final String tag;
  final String imageUrl;
  final String trackKeyword;

  const StoryItem({
    required this.id,
    required this.tag,
    required this.imageUrl,
    required this.trackKeyword,
  });
}
