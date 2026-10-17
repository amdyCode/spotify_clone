import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/catalog_controller.dart';
import '../controllers/player_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/mix_card_widget.dart';
import '../widgets/track_tile_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = Get.find<CatalogController>();
    final player = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (catalog.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.spotifyGreen),
            );
          }

          final quickMix = catalog.quickMix.value;
          final tracks = catalog.tracks;
          final mixes = catalog.mixes;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.0,
              children: [
                // 1. En-tête : Avatar profil "A" + Filtres en pilules ("Tout", "Musique", "Podcasts")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    spacing: 8.0,
                    children: [
                      // Avatar "A"
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8D4A32),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Chips filtres
                      ...catalog.filters.map((f) {
                        final isSelected = catalog.activeFilter.value == f;
                        return GestureDetector(
                          onTap: () => catalog.setFilter(f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.chipActive : AppColors.chipInactive,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // 2. Bannière raccourci : "Mix Ninho"
                if (quickMix != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Row(
                        spacing: 12.0,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4.0),
                              bottomLeft: Radius.circular(4.0),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: quickMix.cover,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 56,
                                height: 56,
                                color: AppColors.surfaceElevated,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              quickMix.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_horiz, color: AppColors.spotifyGreen, size: 22),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),

                // 3. Section "Lancer la lecture" avec sous-titre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4.0,
                    children: [
                      if (quickMix != null)
                        Text(
                          quickMix.subtitle,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      const Text(
                        'Lancer la lecture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste verticale des 5 titres
                Column(
                  children: tracks.map((track) {
                    return TrackTileWidget(track: track);
                  }).toList(),
                ),

                // 4. Section "Pour commencer"
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Pour commencer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // Défilement horizontal des Mixes (Mix Damso, Mix Soolking)
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: mixes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final mix = mixes[index];
                      return MixCardWidget(
                        mix: mix,
                        onTap: () {
                          // Joue le premier titre associé au mix
                          if (tracks.isNotEmpty) {
                            final target = tracks.firstWhere(
                              (t) => t.artist.toLowerCase().contains(mix.title.toLowerCase().replaceAll('mix ', '')),
                              orElse: () => tracks.first,
                            );
                            player.playTrack(target);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
