import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/mix.dart';
import '../theme/app_theme.dart';

class MixCardWidget extends StatelessWidget {
  final Mix mix;
  final VoidCallback? onTap;

  const MixCardWidget({
    super.key,
    required this.mix,
    this.onTap,
  });

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.spotifyGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bandColor = _parseColor(mix.tagColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.0),
      child: SizedBox(
        width: 155,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: [
            // Carte carrée
            Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                color: AppColors.surface,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Image
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: mix.cover,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppColors.surface),
                      errorWidget: (context, url, error) => Container(color: AppColors.surface),
                    ),
                  ),
                  // Spotify icon top left
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: FaIcon(
                      FontAwesomeIcons.spotify,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  // Bandeau inférieur avec le nom du Mix
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      color: bandColor,
                      child: Text(
                        mix.tag,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Sous-titre
            Text(
              mix.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
