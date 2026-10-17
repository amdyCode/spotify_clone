import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/player_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player_widget.dart';
import '../widgets/spotify_library_icon.dart';
import 'home_screen.dart';
import 'search_screen.dart';

class MainLayoutController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutController = Get.put(MainLayoutController());
    final playerController = Get.find<PlayerController>();

    final screens = const [
      HomeScreen(),
      SearchScreen(),
      Center(
        child: Text(
          'Bibliothèque',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Écran courant
          Obx(() => screens[layoutController.selectedIndex.value]),

          // Overlay inférieur : Dégradé + Mini-Lecteur + Barre 5 onglets
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.85),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.4, 0.8],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini-Lecteur flottant si un morceau est chargé
                    Obx(() {
                      if (playerController.currentTrack.value != null) {
                        return const MiniPlayerWidget();
                      }
                      return const SizedBox.shrink();
                    }),

                    // Barre de navigation personnalisée à 5 onglets
                    Container(
                      padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
                      child: Obx(() {
                        final current = layoutController.selectedIndex.value;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTabItem(
                              icon: current == 0
                                  ? Icons.home
                                  : Icons.home_outlined,
                              label: 'Accueil',
                              isSelected: current == 0,
                              onTap: () => layoutController.changeIndex(0),
                            ),
                            _buildTabItem(
                              icon: Icons.search,
                              label: 'Rechercher',
                              isSelected: current == 1,
                              onTap: () => layoutController.changeIndex(1),
                            ),
                            _buildCustomTabItem(
                              iconWidget: SpotifyLibraryIcon(
                                color: current == 2
                                    ? Colors.white
                                    : AppColors.textMuted,
                                size: 22,
                              ),
                              label: 'Bibliothèque',
                              isSelected: current == 2,
                              onTap: () => layoutController.changeIndex(2),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 4.0,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabItem({
    required Widget iconWidget,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 4.0,
        children: [
          SizedBox(height: 26, child: Center(child: iconWidget)),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
