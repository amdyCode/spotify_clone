import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify_clone/utils/app_colors.dart';
import 'package:spotify_clone/widgets/open_context_menu.dart';
import 'package:spotify_clone/widgets/open_queue_modal.dart';
import '../controllers/player_controller.dart';
import '../models/track.dart';
import '../utils/context_extensions.dart';
import '../widgets/lyrics_preview_widget.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  Color _parseTrackColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF301216);
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

      // Affichage basé uniquement sur les 30 secondes de l'extrait
      const previewDurationSec = 30;
      const previewTotalMs = 30000.0;
      final currentMs = player.position.value.inMilliseconds.toDouble().clamp(0.0, previewTotalMs);
      final currentSeconds = (currentMs / 1000).floor().clamp(0, previewDurationSec);
      final remainingSeconds = (previewDurationSec - currentSeconds).clamp(0, previewDurationSec);

      final dominantColor = _parseTrackColor(track.color);

      return GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            Get.back();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  dominantColor,
                  dominantColor.withValues(alpha: 0.6),
                  const Color(0xFF121212),
                ],
                stops: const [0.0, 0.45, 0.9],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 36,
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
                                  'PLAYING FROM ARTIST',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  track.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              size: 26,
                              color: Colors.white,
                            ),
                            onPressed: () => _openContextMenu(context, track, player),
                          ),
                        ],
                      ),
                    ),

                    // Grande pochette carrée de l'album
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Center(
                        child: Container(
                          width: context.screenWidth - 48,
                          height: context.screenWidth - 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
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
                              placeholder: (context, url) => Container(color: AppColors.surface),
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
                    ),

                    if (track.quoteLyric != null && track.quoteLyric!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                        child: Text(
                          track.quoteLyric!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                Row(
                                  children: [
                                    if (track.explicit) ...[
                                      Container(
                                        margin: const EdgeInsets.only(right: 6.0),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                          vertical: 1.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          borderRadius: BorderRadius.circular(2.0),
                                        ),
                                        child: const Text(
                                          'E',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                    Expanded(
                                      child: Text(
                                        track.artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.check_circle : Icons.add_circle_outline,
                              color: isLiked ? AppColors.spotifyGreen : Colors.white,
                              size: 32,
                            ),
                            onPressed: () => player.toggleLike(track.id),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
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
                              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
                              thumbColor: Colors.white,
                              overlayColor: Colors.white.withValues(alpha: 0.15),
                            ),
                            child: Slider(
                              value: currentMs,
                              min: 0.0,
                              max: previewTotalMs,
                              onChanged: (val) {
                                player.seek(Duration(milliseconds: val.toInt()));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(Duration(seconds: currentSeconds)),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '-${_formatDuration(Duration(seconds: remainingSeconds))}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.shuffle,
                                  size: 26,
                                  color: isShuffle ? AppColors.spotifyGreen : Colors.white,
                                ),
                                onPressed: player.toggleShuffle,
                              ),
                              if (isShuffle)
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.spotifyGreen,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                const SizedBox(height: 4),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.skip_previous,
                              size: 42,
                              color: Colors.white,
                            ),
                            onPressed: player.playPrevious,
                          ),
                          GestureDetector(
                            onTap: player.togglePlayPause,
                            child: Container(
                              width: 66,
                              height: 66,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                                size: 38,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next,
                              size: 42,
                              color: Colors.white,
                            ),
                            onPressed: player.playNext,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.timer_outlined,
                              size: 26,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Get.snackbar(
                                'Minuteur de veille',
                                'Arrêt de la lecture dans 30 minutes.',
                                backgroundColor: AppColors.surface,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.devices_outlined,
                              color: Colors.white70,
                              size: 22,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Row(
                            spacing: 24.0,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.share_outlined,
                                  color: Colors.white70,
                                  size: 22,
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
                                  Icons.queue_music,
                                  color: Colors.white70,
                                  size: 24,
                                ),
                                onPressed: () => _openQueueModal(context, player),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    LyricsPreviewWidget(track: track),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _openContextMenu(BuildContext context, Track track, PlayerController player) {
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
