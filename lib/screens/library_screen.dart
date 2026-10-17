import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotify_clone/controllers/library_controller.dart';
import 'package:spotify_clone/widgets/library_item.dart';
import 'package:spotify_clone/widgets/liked_songs_title.dart';
import '../controllers/catalog_controller.dart';
import '../controllers/player_controller.dart';
import '../theme/app_theme.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraryController = Get.put(LibraryController());
    final playerController = Get.find<PlayerController>();
    final catalogController = Get.find<CatalogController>();

    final filters = const ['Playlists', 'Artistes', 'Albums'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
                child: Row(
                  spacing: 12.0,
                  children: [
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
                    const Expanded(
                      child: Text(
                        'Votre bibliothèque',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white, size: 24),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 28),
                      onPressed: () {
                        Get.snackbar(
                          'Créer',
                          'Création de playlist bientôt disponible.',
                          backgroundColor: AppColors.surface,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),

            // Filtres en pilules ("Playlists", "Artistes", "Albums")
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Obx(() {
                  return Row(
                    spacing: 8.0,
                    children: filters.map((f) {
                      final isSelected = libraryController.selectedFilter.value == f;
                      return GestureDetector(
                        onTap: () => libraryController.toggleFilter(f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.spotifyGreen : AppColors.chipInactive,
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
                    }).toList(),
                  );
                }),
              ),
            ),

            // Barre de tri & vue ("Récents" / Grille)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 6.0,
                      children: const [
                        Icon(Icons.swap_vert, color: Colors.white, size: 20),
                        Text(
                          'Récents',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.grid_view_outlined, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),

            // Liste des éléments de la bibliothèque
            SliverToBoxAdapter(
              child: Obx(() {
                final filter = libraryController.selectedFilter.value;
                final likedTracks = playerController.likedTracksList;
                final mixes = catalogController.mixes;
                final tracks = catalogController.tracks;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 120.0),
                  child: Column(
                    children: [
                      if (filter.isEmpty || filter == 'Playlists')
                        LikedSongsTitle(likedTracks: likedTracks, playerController: playerController),

                      if (filter.isEmpty || filter == 'Playlists')
                        ...mixes.map((mix) {
                          return LibraryItem(
                            title: mix.title,
                            subtitle: 'Playlist • Spotify',
                            imageUrl: mix.cover,
                            isCircle: false,
                            onTap: () {
                              if (tracks.isNotEmpty) {
                                final target = tracks.firstWhere(
                                  (t) => t.artist.toLowerCase().contains(mix.title.toLowerCase().replaceAll('mix ', '')),
                                  orElse: () => tracks.first,
                                );
                                playerController.playTrack(target, tracks);
                              }
                            },
                          );
                        }),

                      // Artistes
                      if (filter.isEmpty || filter == 'Artistes')
                        ...tracks.map((t) {
                          return LibraryItem(
                            title: t.artist,
                            subtitle: 'Artiste',
                            imageUrl: t.cover,
                            isCircle: true,
                            onTap: () => playerController.playTrack(t, tracks),
                          );
                        }),

                      // Albums
                      if (filter.isEmpty || filter == 'Albums')
                        ...tracks.map((t) {
                          return LibraryItem(
                            title: t.album,
                            subtitle: 'Album • ${t.artist}',
                            imageUrl: t.cover,
                            isCircle: false,
                            onTap: () => playerController.playTrack(t, tracks),
                          );
                        }),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
