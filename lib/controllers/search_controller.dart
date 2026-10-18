import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/search_category.dart';
import '../models/track.dart';
import '../services/deezer_service.dart';
import 'catalog_controller.dart';

class SearchScreenController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  final RxString query = ''.obs;
  final RxBool isSearching = false.obs;
  final RxList<Track> searchResults = <Track>[].obs;

  Timer? _debounceTimer;

  final List<StoryItem> stories = const [
    StoryItem(
      id: 'story-1',
      tag: '#rap calme',
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600&q=80',
      trackKeyword: 'rap calme',
    ),
    StoryItem(
      id: 'story-2',
      tag: '#logobi',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600&q=80',
      trackKeyword: 'logobi',
    ),
    StoryItem(
      id: 'story-3',
      tag: '#indie fr',
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&q=80',
      trackKeyword: 'indie',
    ),
  ];

  final List<SearchCategory> categories = const [
    SearchCategory(
      id: 'music',
      title: 'Musique',
      color: Color(0xFFE1118C),
      imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/ab/c5/ea/abc5eab6-1a33-3910-6f96-3954d76c5815/190295460259.jpg/300x300bb.jpg',
    ),
    SearchCategory(
      id: 'podcasts',
      title: 'Podcasts',
      color: Color(0xFF006450),
      imageUrl: 'https://images.unsplash.com/photo-1478737270239-2f02b77fc618?w=300&q=80',
    ),
    SearchCategory(
      id: 'events',
      title: 'Événements en direct',
      color: Color(0xFF8400E7),
      imageUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=300&q=80',
    ),
    SearchCategory(
      id: 'made_for_you',
      title: 'Conçu spécialement pour vous',
      color: Color(0xFF8D67AB),
      imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/38/72/43/3872430c-bb7d-f78d-5011-27f69616dee4/190295332181.jpg/300x300bb.jpg',
    ),
    SearchCategory(
      id: 'charts',
      title: 'Classements',
      color: Color(0xFF1E3264),
      imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/29/e0/7f/29e07f75-649d-2b00-4758-70e44652dfde/25UMGIM12360.rgb.jpg/300x300bb.jpg',
    ),
    SearchCategory(
      id: 'new_releases',
      title: 'Nouveautés',
      color: Color(0xFFE86328),
      imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/5b/0f/59/5b0f597c-f337-93c1-445d-26b12160c8c6/16UMGIM34250.rgb.jpg/300x300bb.jpg',
    ),
    SearchCategory(
      id: 'hip_hop',
      title: 'Hip-hop',
      color: Color(0xFF477D95),
      imageUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/03/bc/9a/03bc9ab3-61c0-dadd-5cb6-9b52b30af140/190295530631.jpg/300x300bb.jpg',
    ),
    SearchCategory(
      id: 'mood',
      title: 'Ambiance',
      color: Color(0xFF503750),
      imageUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=300&q=80',
    ),
  ];

  void onQueryChanged(String val) {
    query.value = val;
    _debounceTimer?.cancel();

    if (val.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(val.trim());
    });
  }

  Future<void> _performSearch(String searchTerm) async {
    isSearching.value = true;
    final List<Track> combinedResults = [];

    // 1. Filtrer les titres locaux
    try {
      final catalogController = Get.find<CatalogController>();
      final localMatches = catalogController.tracks.where((t) =>
        t.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
        t.artist.toLowerCase().contains(searchTerm.toLowerCase())
      ).toList();
      combinedResults.addAll(localMatches);
    } catch (_) {}

    try {
      final deezerMatches = await DeezerService.searchTracks(searchTerm);
      for (final track in deezerMatches) {
        if (!combinedResults.any((t) => t.id == track.id)) {
          combinedResults.add(track);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erreur Deezer search: $e');
    } finally {
      searchResults.assignAll(combinedResults);
      isSearching.value = false;
    }
  }

  void clearQuery() {
    textEditingController.clear();
    query.value = '';
    searchResults.clear();
    isSearching.value = false;
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    textEditingController.dispose();
    super.onClose();
  }
}
