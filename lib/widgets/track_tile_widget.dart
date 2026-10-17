import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';
import '../models/track.dart';
import 'package:spotify_clone/utils/app_colors.dart';

class TrackTileWidget extends StatelessWidget {
  final Track track;

  const TrackTileWidget({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();

    return InkWell(
      onTap: () => playerController.playTrack(track),
      borderRadius: BorderRadius.circular(6.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          spacing: 12.0,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: CachedNetworkImage(
                imageUrl: track.cover,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surface,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 48,
                  height: 48,
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
                  Obx(() {
                    final isCurrent = playerController.currentTrack.value?.id == track.id;
                    return Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent ? AppColors.spotifyGreen : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                  Row(
                    spacing: 6.0,
                    children: [
                      if (track.explicit)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB3B3B3),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: const Text(
                            'E',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
              onPressed: () {},
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
