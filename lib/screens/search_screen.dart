import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/category_tile_widget.dart';
import '../widgets/story_card_widget.dart';
import '../widgets/track_tile_widget.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(SearchScreenController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // 1. En-tête : Avatar "A", Titre "Rechercher", Icône Caméra
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
                child: Row(
                  spacing: 12.0,
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
                    const Expanded(
                      child: Text(
                        'Rechercher',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26),
                      onPressed: () {
                        Get.snackbar(
                          'Spotify Code',
                          'Scannez un code Spotify pour écouter instantanément.',
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

            // 2. Barre de recherche épinglée / Stylisée
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Row(
                    spacing: 10.0,
                    children: [
                      const Icon(Icons.search, size: 24, color: Color(0xFF121212)),
                      Expanded(
                        child: TextField(
                          controller: searchController.textEditingController,
                          onChanged: searchController.onQueryChanged,
                          style: const TextStyle(
                            color: Color(0xFF121212),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Que souhaitez-vous écouter ?',
                            hintStyle: TextStyle(
                              color: Color(0xFF535353),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Obx(() {
                        if (searchController.query.value.isNotEmpty) {
                          return GestureDetector(
                            onTap: searchController.clearQuery,
                            child: const Icon(Icons.close, color: Color(0xFF121212), size: 20),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Contenu : Résultats de recherche OU Découverte & Parcourir tout
            SliverToBoxAdapter(
              child: Obx(() {
                final isQuerying = searchController.query.value.trim().isNotEmpty;

                if (isQuerying) {
                  if (searchController.isSearching.value) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 60.0),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.spotifyGreen),
                      ),
                    );
                  }

                  final results = searchController.searchResults;
                  if (results.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Center(
                        child: Text(
                          'Aucun résultat pour « ${searchController.query.value} »',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 120.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: results.map((track) {
                        return TrackTileWidget(track: track);
                      }).toList(),
                    ),
                  );
                }

                // Vue standard conforme à la Capture 3
                return Padding(
                  padding: const EdgeInsets.only(bottom: 120.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16.0,
                    children: [
                      // Section "Découvrez de nouveaux horizons"
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                        child: Text(
                          'Découvrez de nouveaux horizons',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      // Liste horizontale des Stories
                      SizedBox(
                        height: 215,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: searchController.stories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final story = searchController.stories[index];
                            return StoryCardWidget(
                              story: story,
                              onTap: () {
                                searchController.textEditingController.text = story.trackKeyword;
                                searchController.onQueryChanged(story.trackKeyword);
                              },
                            );
                          },
                        ),
                      ),

                      // Section "Tout parcourir"
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                        child: Text(
                          'Tout parcourir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      // Grille 2 colonnes des catégories
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 110,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: searchController.categories.length,
                          itemBuilder: (context, index) {
                            final cat = searchController.categories[index];
                            return CategoryTileWidget(
                              category: cat,
                              onTap: () {
                                searchController.textEditingController.text = cat.title;
                                searchController.onQueryChanged(cat.title);
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
          ],
        ),
      ),
    );
  }
}
