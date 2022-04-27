class TVShowPreview {
  final String id;
  final String name;
  final String? imageUrl;
  final String year;
  final bool isFavorite;
  final double rating;
  String overview;

  TVShowPreview({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.year,
    required this.isFavorite,
    required this.overview,
    required this.rating,
  });
}
