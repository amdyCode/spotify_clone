import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';
import '../screens/now_playing_screen.dart';
import 'package:spotify_clone/utils/app_colors.dart';

class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget({super.key});

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  double _dragOffset = 0.0;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null && (details.primaryDelta! > 0 || _dragOffset > 0)) {
      setState(() {
        _dragOffset = (_dragOffset + details.primaryDelta!).clamp(0.0, 120.0);
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    if (_dragOffset > 20.0 || velocity > 200.0) {
      final playerController = Get.find<PlayerController>();
      playerController.stopPlayer();
      if (mounted) {
        setState(() {
          _dragOffset = 0.0;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _dragOffset = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();

    return Obx(() {
      final track = playerController.currentTrack.value;
      if (track == null) return const SizedBox.shrink();

      final isPlaying = playerController.isPlaying.value;
      final isLiked = playerController.isLiked(track.id);

      final totalMs = playerController.duration.value.inMilliseconds;
      final currentMs = playerController.position.value.inMilliseconds;
      final progress = totalMs > 0 ? (currentMs / totalMs).clamp(0.0, 1.0) : 0.0;

      return Transform.translate(
        offset: Offset(0, _dragOffset),
        child: GestureDetector(
          onTap: () {
            Get.to(
              () => const NowPlayingScreen(),
              transition: Transition.downToUp,
              duration: const Duration(milliseconds: 300),
            );
          },
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: AppColors.miniPlayerBg,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  child: Row(
                    spacing: 12.0,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: CachedNetworkImage(
                          imageUrl: track.cover,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 44,
                            height: 44,
                            color: AppColors.surface,
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 44,
                            height: 44,
                            color: AppColors.surface,
                            child: const Icon(Icons.music_note, color: Colors.white54),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 2.0,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8.0,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.devices_outlined, color: Colors.white, size: 22),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.check_circle : Icons.add_circle_outline,
                              color: isLiked ? AppColors.spotifyGreen : Colors.white,
                              size: 24,
                            ),
                            onPressed: () => playerController.toggleLike(track.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: playerController.togglePlayPause,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Barre de progression fine
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      );
    });
  }
}
