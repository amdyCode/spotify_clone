import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';
import '../models/track.dart';
import '../utils/app_colors.dart';

class LyricsScreen extends StatefulWidget {
  final Track track;

  const LyricsScreen({super.key, required this.track});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _lastActiveIndex = -1;

  Color _parseLyricBgColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF4A121A);
    }
  }

  int _calculateActiveIndex(Duration position, Duration total, int lyricsCount) {
    if (lyricsCount == 0) return 0;
    final totalMs = total.inMilliseconds > 0 ? total.inMilliseconds : 30000;
    final lineDurationMs = totalMs / lyricsCount;
    final index = (position.inMilliseconds / lineDurationMs).floor();
    return index.clamp(0, lyricsCount - 1);
  }

  void _scrollToActiveIndex(int index) {
    if (!_scrollController.hasClients) return;
    const itemHeight = 65.0;
    final targetOffset = (index * itemHeight) - 150.0;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    final bgColor = _parseLyricBgColor(widget.track.color);
    final lyrics = widget.track.lyrics;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 34, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2.0,
                      children: [
                        Text(
                          widget.track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
                    onPressed: () {
                      Get.snackbar(
                        'Paroles',
                        'Paroles partagées avec succès !',
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

            // Lyrics List
            Expanded(
              child: Obx(() {
                final currentPos = player.position.value;
                final totalDur = player.duration.value;
                final activeIndex = _calculateActiveIndex(currentPos, totalDur, lyrics.length);

                if (activeIndex != _lastActiveIndex) {
                  _lastActiveIndex = activeIndex;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToActiveIndex(activeIndex);
                  });
                }

                if (lyrics.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune parole disponible pour ce titre.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  itemCount: lyrics.length,
                  itemBuilder: (context, index) {
                    final isCurrent = index == activeIndex;
                    final isPast = index < activeIndex;

                    return GestureDetector(
                      onTap: () {
                        final totalMs = totalDur.inMilliseconds > 0 ? totalDur.inMilliseconds : 30000;
                        final seekMs = (index * (totalMs / lyrics.length)).toInt();
                        player.seek(Duration(milliseconds: seekMs));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: isCurrent
                                ? Colors.white
                                : (isPast
                                    ? Colors.white.withValues(alpha: 0.75)
                                    : Colors.white.withValues(alpha: 0.35)),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          child: Text(lyrics[index]),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Bottom mini playback bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    bgColor,
                    bgColor.withValues(alpha: 0.95),
                    bgColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Obx(() {
                final isPlaying = player.isPlaying.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 36, color: Colors.white),
                      onPressed: player.playPrevious,
                    ),
                    GestureDetector(
                      onTap: player.togglePlayPause,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 36, color: Colors.white),
                      onPressed: player.playNext,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
