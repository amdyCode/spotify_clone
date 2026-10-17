import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify_clone/controllers/player_controller.dart';
import 'package:spotify_clone/models/track.dart';
import 'package:spotify_clone/theme/app_theme.dart';
import 'package:spotify_clone/widgets/track_tile_widget.dart';

class LikedSongsTitle extends StatelessWidget {
  final List<Track> likedTracks;
  final PlayerController playerController;
  const LikedSongsTitle({super.key, required this.likedTracks, required this.playerController});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openLikedTracksModal(context, likedTracks, playerController),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          spacing: 12.0,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4A148C),
                    Color(0xFF7B1FA2),
                    Color(0xFF1E88E5),
                  ],
                ),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 28),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.0,
                children: [
                  const Text(
                    'Titres likés',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    spacing: 4.0,
                    children: [
                      const Icon(Icons.push_pin, color: AppColors.spotifyGreen, size: 14),
                      Text(
                        'Playlist • ${likedTracks.length} titres',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _openLikedTracksModal(
    BuildContext context,
    List<Track> likedTracks,
    PlayerController playerController,
  ) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.heightOf(context) * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          children: [
            // Barre supérieure avec poignée
            Container(
              margin: const EdgeInsets.only(top: 8.0, bottom: 12.0),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            // En-tête Titres Likés
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4.0,
                    children: [
                      const Text(
                        'Titres likés',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${likedTracks.length} titres enregistrés',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                  if (likedTracks.isNotEmpty)
                    FloatingActionButton.small(
                      backgroundColor: AppColors.spotifyGreen,
                      onPressed: () {
                        playerController.playTrack(likedTracks.first, likedTracks);
                      },
                      child: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
                    ),
                ],
              ),
            ),
            const Divider(color: AppColors.surface, height: 16),
            // Liste des morceaux
            Expanded(
              child: likedTracks.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun titre liké pour le moment.\nTouchez l\'icône cœur pour en ajouter !',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      itemCount: likedTracks.length,
                      itemBuilder: (context, index) {
                        final track = likedTracks[index];
                        return TrackTileWidget(track: track);
                      },
                    ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

}