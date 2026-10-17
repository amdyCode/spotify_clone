import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify_clone/utils/app_colors.dart';
import 'package:spotify_clone/widgets/open_context_menu.dart';
import 'package:spotify_clone/widgets/open_queue_modal.dart';
import '../controllers/player_controller.dart';
import '../models/track.dart';
import '../utils/context_extensions.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  Color _parseTrackColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF2E2E2E);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();

    return Obx(() {
      final track = player.currentTrack.value;
      if (track == null) {
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Text(
              'Aucun titre en cours de lecture',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }

      final isPlaying = player.isPlaying.value;
      final isLiked = player.isLiked(track.id);
      final isShuffle = player.isShuffle.value;
      final isRepeat = player.isRepeat.value;

      final currentMs = player.position.value.inMilliseconds.toDouble();
      final totalMs = player.duration.value.inMilliseconds.toDouble();
      final maxVal = totalMs > 0 ? totalMs : 30000.0;
      final clampedCurrent = currentMs.clamp(0.0, maxVal);

      final dominantColor = _parseTrackColor(track.color);

      return GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            Get.back();
          }
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  dominantColor.withValues(alpha: 0.85),
                  dominantColor.withValues(alpha: 0.35),
                  AppColors.background,
                ],
                stops: const [0.0, 0.45, 0.85],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            size: 32,
                            color: Colors.white,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 2.0,
                            children: [
                              const Text(
                                "EN LECTURE DEPUIS L'ALBUM",
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                track.album.isNotEmpty
                                    ? track.album
                                    : track.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            size: 24,
                            color: Colors.white,
                          ),
                          onPressed: () =>
                              _openContextMenu(context, track, player),
                        ),
                      ],
                    ),

                    // Grande pochette d'album carrée
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        width: context.screenWidth - 48,
                        height: context.screenWidth - 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: track.cover,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: AppColors.surface),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.surface,
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white54,
                                size: 64,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 12.0,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4.0,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                track.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked
                                ? AppColors.spotifyGreen
                                : Colors.white,
                            size: 28,
                          ),
                          onPressed: () => player.toggleLike(track.id),
                        ),
                      ],
                    ),

                    // Barre de progression (Slider interactif) + Temps écoulé / restant
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.5,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14.0,
                            ),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withValues(
                              alpha: 0.25,
                            ),
                            thumbColor: Colors.white,
                            overlayColor: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: Slider(
                            value: clampedCurrent,
                            min: 0.0,
                            max: maxVal,
                            onChanged: (val) {
                              player.seek(Duration(milliseconds: val.toInt()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(player.position.value),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(
                                  player.duration.value.inSeconds > 0
                                      ? player.duration.value
                                      : const Duration(seconds: 30),
                                ),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            size: 24,
                            color: isShuffle
                                ? AppColors.spotifyGreen
                                : AppColors.textMuted,
                          ),
                          onPressed: player.toggleShuffle,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            size: 38,
                            color: Colors.white,
                          ),
                          onPressed: player.playPrevious,
                        ),
                        GestureDetector(
                          onTap: player.togglePlayPause,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 34,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            size: 38,
                            color: Colors.white,
                          ),
                          onPressed: player.playNext,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.repeat,
                            size: 24,
                            color: isRepeat
                                ? AppColors.spotifyGreen
                                : AppColors.textMuted,
                          ),
                          onPressed: player.toggleRepeat,
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          spacing: 16.0,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.share_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                Get.snackbar(
                                  'Partager',
                                  'Lien du titre copié dans le presse-papier !',
                                  backgroundColor: AppColors.surface,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.queue_music_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: () {
                                _openQueueModal(context, player);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _openContextMenu(
    BuildContext context,
    Track track,
    PlayerController player,
  ) {
    Get.bottomSheet(
      OpenContextMenu(track: track, player: player),
      isScrollControlled: true,
    );
  }

  void _openQueueModal(BuildContext context, PlayerController player) {
    Get.bottomSheet(
      OpenQueueModal(player: player),
      isScrollControlled: true,
    );
  }
}
