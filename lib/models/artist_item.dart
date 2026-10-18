class ArtistItem {
  final String id;
  final String name;
  final String picture;

  const ArtistItem({
    required this.id,
    required this.name,
    required this.picture,
  });

  factory ArtistItem.fromJson(Map<String, dynamic> json) {
    return ArtistItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      picture: json['picture'] as String? ?? '',
    );
  }
}