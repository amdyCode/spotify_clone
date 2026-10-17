import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track.dart';

class PlayerController extends GetxController {
  final AudioPlayer _player = AudioPlayer();

  final Rx<Track?> currentTrack = Rx<Track?>(null);
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxSet<String> likedTrackIds = <String>{}.obs;

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
        position.value = Duration.zero;
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
      final List<String>? saved = prefs.getStringList('liked_tracks');
      if (saved != null) {
        likedTrackIds.assignAll(saved);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erreur favoris: $e');
    }
  }

  Future<void> playTrack(Track track) async {
    try {
      currentTrack.value = track;
      await _player.setUrl(track.previewUrl);
      await _player.play();
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lecture track: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (currentTrack.value == null) return;
    if (isPlaying.value) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> toggleLike(String trackId) async {
    if (likedTrackIds.contains(trackId)) {
      likedTrackIds.remove(trackId);
    } else {
      likedTrackIds.add(trackId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('liked_tracks', likedTrackIds.toList());
  }

  bool isLiked(String trackId) => likedTrackIds.contains(trackId);

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
