import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify_clone/controllers/player_controller.dart';
import 'package:spotify_clone/theme/app_theme.dart';

class OpenQueueModal extends StatelessWidget {
  final PlayerController player;
  const OpenQueueModal({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.heightOf(context) * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "File d'attente",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.surface),
            Expanded(
              child: Obx(() {
                final queue = player.currentQueue;
                if (queue.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun titre dans la file d'attente",
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final item = queue[index];
                    final isPlayingThis =
                        player.currentTrack.value?.id == item.id;
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: CachedNetworkImage(
                          imageUrl: item.cover,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlayingThis
                              ? AppColors.spotifyGreen
                              : Colors.white,
                          fontWeight: isPlayingThis
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        item.artist,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      trailing: isPlayingThis
                          ? const Icon(
                              Icons.equalizer,
                              color: AppColors.spotifyGreen,
                            )
                          : null,
                      onTap: () {
                        player.playTrack(item, queue);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      );
  }
}