import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';
import '../models/track.dart';
import '../screens/lyrics_screen.dart';

class LyricsPreviewWidget extends StatelessWidget {
  final Track track;

  const LyricsPreviewWidget({super.key, required this.track});

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

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    final cardColor = _parseLyricBgColor(track.color);
    final lyrics = track.lyrics;

    if (lyrics.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Get.to(
          () => LyricsScreen(track: track),
          transition: Transition.downToUp,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12.0,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lyrics preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                Row(
                  spacing: 12.0,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.open_in_full,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Extrait des paroles avec mise en surbrillance dynamique
            Obx(() {
              final currentPos = player.position.value;
              final totalDur = player.duration.value;
              final activeIndex = _calculateActiveIndex(currentPos, totalDur, lyrics.length);

              // Affiche jusqu'à 3-4 lignes autour de la ligne active
              final startIndex = (activeIndex - 1).clamp(0, lyrics.length - 1);
              final endIndex = (startIndex + 4).clamp(0, lyrics.length);
              final visibleLines = lyrics.sublist(startIndex, endIndex);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8.0,
                children: visibleLines.map((line) {
                  final isCurrent = line == lyrics[activeIndex];
                  return Text(
                    line,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCurrent
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
