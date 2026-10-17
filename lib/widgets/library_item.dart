import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spotify_clone/theme/app_theme.dart';

class LibraryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isCircle;
  final VoidCallback onTap;
  const LibraryItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.isCircle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          spacing: 12.0,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(isCircle ? 32.0 : 4.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(width: 64, height: 64, color: AppColors.surface),
                errorWidget: (context, url, error) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.surface,
                  child: const Icon(Icons.music_note, color: Colors.white38),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.0,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
