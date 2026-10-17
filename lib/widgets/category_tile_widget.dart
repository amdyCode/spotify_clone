import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/search_category.dart';

class CategoryTileWidget extends StatelessWidget {
  final SearchCategory category;
  final VoidCallback? onTap;

  const CategoryTileWidget({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.0),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(6.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Titre en haut à gauche
            Positioned(
              top: 12,
              left: 12,
              right: 48,
              child: Text(
                category.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            // Image inclinée à 25 degrés qui dépasse en bas à droite
            Positioned(
              right: -12,
              bottom: -6,
              child: Transform.rotate(
                angle: 25 * math.pi / 180,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: CachedNetworkImage(
                      imageUrl: category.imageUrl,
                      width: 66,
                      height: 66,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 66,
                        height: 66,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 66,
                        height: 66,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
