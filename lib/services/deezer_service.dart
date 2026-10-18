import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/track.dart';

class DeezerService {
  static final Map<int, (String url, DateTime expiresAt)> _cache = {};

  static Future<String?> getPreview(int deezerId) async {
    final cached = _cache[deezerId];
    if (cached != null && DateTime.now().isBefore(cached.$2)) {
      return cached.$1;
    }

    try {
      final uri = Uri.parse('https://api.deezer.com/track/$deezerId');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final preview = data['preview'] as String?;
        if (preview != null && preview.isNotEmpty) {
          _cache[deezerId] = (
            preview,
            DateTime.now().add(const Duration(minutes: 10)),
          );
          return preview;
        }
      }
    } catch (e) {
      debugPrint('Erreur Deezer preview: $e');
    }
    return null;
  }

  static Future<List<Track>> searchTracks(String query) async {
    try {
      final uri = Uri.parse('https://api.deezer.com/search?q=${Uri.encodeComponent(query)}&limit=15');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data'] ?? [];

        return items.map((item) {
          final id = item['id'].toString();
          final deezerId = item['id'] as int?;
          final title = item['title'] as String? ?? 'Titre inconnu';
          final artist = item['artist']?['name'] as String? ?? 'Artiste inconnu';
          final album = item['album']?['title'] as String? ?? '';
          final cover = item['album']?['cover_big'] as String? ??
              item['album']?['cover_medium'] as String? ?? '';
          final preview = item['preview'] as String? ?? '';
          final durationSec = item['duration'] as int? ?? 30;
          final explicit = item['explicit_lyrics'] as bool? ?? false;

          return Track(
            id: id,
            title: title,
            artist: artist,
            album: album,
            cover: cover,
            previewUrl: preview,
            deezerId: deezerId,
            durationMs: durationSec * 1000,
            explicit: explicit,
            color: '#1E1E1E',
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Erreur Deezer search: $e');
    }
    return [];
  }
}

