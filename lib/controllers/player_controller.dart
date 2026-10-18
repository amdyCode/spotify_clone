import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track.dart';
import '../services/deezer_service.dart';
import 'catalog_controller.dart';

class PlayerController extends GetxController {
  final AudioPlayer _player = AudioPlayer();

  final Rx<Track?> currentTrack = Rx<Track?>(null);
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxSet<String> likedTrackIds = <String>{}.obs;
  final RxList<Track> likedTracksList = <Track>[].obs;

  final RxList<Track> currentQueue = <Track>[].obs;
  final RxInt currentQueueIndex = 0.obs;
  final RxBool isShuffle = false.obs;
  final RxBool isRepeat = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAudioStreams();
    _loadFavorites();
  }

  void _initAudioStreams() {
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing && state.processingState != ProcessingState.completed;
      if (state.processingState == ProcessingState.completed) {
        if (isRepeat.value && currentTrack.value != null) {
          seek(Duration.zero).then((_) => _player.play());
        } else {
          position.value = Duration.zero;
          playNext();
        }
      }
    });

    _player.positionStream.listen((pos) {
      position.value = pos;
    });

    _player.durationStream.listen((dur) {
      duration.value = dur ?? Duration.zero;
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedIds = prefs.getStringList('liked_tracks');
      if (savedIds != null) {
        likedTrackIds.assignAll(savedIds);
      }

      final String? savedTracksJson = prefs.getString('liked_tracks_data');
      if (savedTracksJson != null && savedTracksJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(savedTracksJson);
        likedTracksList.assignAll(decoded.map((e) => Track.fromJson(e)).toList());
      } else {
        // Initialiser avec les morceaux du catalogue si présents
        try {
          final catalog = Get.find<CatalogController>();
          final matched = catalog.tracks.where((t) => likedTrackIds.contains(t.id)).toList();
          likedTracksList.assignAll(matched);
        } catch (_) {}
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erreur favoris: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('liked_tracks', likedTrackIds.toList());
      final jsonList = likedTracksList.map((t) => t.toJson()).toList();
      await prefs.setString('liked_tracks_data', json.encode(jsonList));
    } catch (e) {
      debugPrint('Erreur sauvegarde favoris: $e');
    }
  }

  Future<void> playTrack(Track track, [List<Track>? queue]) async {
    try {
      if (queue != null && queue.isNotEmpty) {
        currentQueue.assignAll(queue);
        currentQueueIndex.value = queue.indexWhere((t) => t.id == track.id);
        if (currentQueueIndex.value == -1) currentQueueIndex.value = 0;
      } else {
        currentQueue.assignAll([track]);
        currentQueueIndex.value = 0;
      }

      currentTrack.value = track;
      String audioUrl = track.previewUrl;

      if (track.deezerId != null) {
        final deezerUrl = await DeezerService.getPreview(track.deezerId!);
        if (deezerUrl != null && deezerUrl.isNotEmpty) {
          audioUrl = deezerUrl;
        }
      }

      await _player.setUrl(audioUrl);
      await _player.play();
    } catch (e) {
      debugPrint('Erreur lecture track: $e');
    }
  }

  Future<void> playNext() async {
    if (currentQueue.isEmpty) return;
    if (currentQueueIndex.value + 1 < currentQueue.length) {
      currentQueueIndex.value++;
      final nextTrack = currentQueue[currentQueueIndex.value];
      await playTrack(nextTrack, currentQueue);
    }
  }

  Future<void> playPrevious() async {
    if (currentQueue.isEmpty) return;
    if (position.value.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    if (currentQueueIndex.value - 1 >= 0) {
      currentQueueIndex.value--;
      final prevTrack = currentQueue[currentQueueIndex.value];
      await playTrack(prevTrack, currentQueue);
    }
  }

  Future<void> seek(Duration newPosition) async {
    await _player.seek(newPosition);
  }

  Future<void> togglePlayPause() async {
    if (currentTrack.value == null) return;
    if (isPlaying.value) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> toggleLike(String trackId, [Track? explicitTrack]) async {
    if (likedTrackIds.contains(trackId)) {
      likedTrackIds.remove(trackId);
      likedTracksList.removeWhere((t) => t.id == trackId);
    } else {
      likedTrackIds.add(trackId);
      Track? target = explicitTrack;
      if (target == null && currentTrack.value?.id == trackId) {
        target = currentTrack.value;
      }
      if (target == null) {
        try {
          final catalog = Get.find<CatalogController>();
          target = catalog.tracks.firstWhereOrNull((t) => t.id == trackId);
        } catch (_) {}
      }
      if (target != null && !likedTracksList.any((t) => t.id == target!.id)) {
        likedTracksList.insert(0, target);
      }
    }
    await _saveFavorites();
  }

  bool isLiked(String trackId) => likedTrackIds.contains(trackId);

  void toggleShuffle() {
    isShuffle.value = !isShuffle.value;
  }

  void toggleRepeat() {
    isRepeat.value = !isRepeat.value;
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
