import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spotify_clone/models/artist_item.dart';
import '../models/mix.dart';
import '../models/track.dart';

class CatalogController extends GetxController {
  final RxList<Track> tracks = <Track>[].obs;
  final RxList<Mix> mixes = <Mix>[].obs;
  final RxList<ArtistItem> artists = <ArtistItem>[].obs;
  final Rx<QuickMix?> quickMix = Rx<QuickMix?>(null);
  final RxString activeFilter = 'Tout'.obs;
  final RxBool isLoading = true.obs;

  final List<String> filters = const ['Tout', 'Musique', 'Podcasts'];

  @override
  void onInit() {
    super.onInit();
    loadCatalog();
  }

  Future<void> loadCatalog() async {
    try {
      isLoading.value = true;
      final jsonString = await rootBundle.loadString('assets/catalog.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      if (data['quickMix'] != null) {
        quickMix.value = QuickMix.fromJson(data['quickMix']);
      }

      if (data['mixes'] != null) {
        final List<dynamic> mixesList = data['mixes'];
        mixes.assignAll(mixesList.map((e) => Mix.fromJson(e)).toList());
      }

      if (data['artists'] != null) {
        final List<dynamic> artistsList = data['artists'];
        artists.assignAll(artistsList.map((e) => ArtistItem.fromJson(e)).toList());
      }

      if (data['tracks'] != null) {
        final List<dynamic> tracksList = data['tracks'];
        tracks.assignAll(tracksList.map((e) => Track.fromJson(e)).toList());
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors du chargement du catalogue: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    activeFilter.value = filter;
  }
}
