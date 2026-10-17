import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/search_category.dart';
import '../theme/app_theme.dart';

class StoryCardWidget extends StatelessWidget {
  final StoryItem story;
  final VoidCallback? onTap;

  const StoryCardWidget({
    super.key,
    required this.story,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 140,
        height: 215,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: AppColors.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Image d'arrière-plan
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: story.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.surface),
                errorWidget: (context, url, error) => Container(color: AppColors.surface),
              ),
            ),
            // Dégradé sombre en bas pour lisibilité
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.5, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            // Hashtag en bas à gauche
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Text(
                story.tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
