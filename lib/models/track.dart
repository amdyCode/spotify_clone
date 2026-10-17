class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String cover;
  final String previewUrl;
  final int durationMs;
  final bool explicit;
  final String color;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.cover,
    required this.previewUrl,
    required this.durationMs,
    this.explicit = false,
    this.color = '#121212',
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      previewUrl: json['previewUrl'] as String? ?? '',
      durationMs: json['durationMs'] as int? ?? 0,
      explicit: json['explicit'] as bool? ?? false,
      color: json['color'] as String? ?? '#121212',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'cover': cover,
      'previewUrl': previewUrl,
      'durationMs': durationMs,
      'explicit': explicit,
      'color': color,
    };
  }
}
