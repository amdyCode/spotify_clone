import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify_clone/controllers/player_controller.dart';
import 'package:spotify_clone/models/track.dart';
import 'package:spotify_clone/theme/app_theme.dart';

class OpenContextMenu extends StatelessWidget {
  final Track track;
  final PlayerController player;
  const OpenContextMenu({super.key, required this.track, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16.0,
          children: [
            Row(
              spacing: 12.0,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: CachedNetworkImage(
                    imageUrl: track.cover,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.0,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        track.artist,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.surfaceLight),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                player.isLiked(track.id) ? Icons.favorite : Icons.favorite_border,
                color: player.isLiked(track.id) ? AppColors.spotifyGreen : Colors.white,
              ),
              title: Text(
                player.isLiked(track.id) ? 'Retirer des favoris' : 'Ajouter aux favoris',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                player.toggleLike(track.id);
                Get.back();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Ajouter à une playlist', style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline, color: Colors.white),
              title: const Text("Voir l'artiste", style: TextStyle(color: Colors.white)),
              onTap: () => Get.back(),
            ),
          ],
        ),
      );
  }
}