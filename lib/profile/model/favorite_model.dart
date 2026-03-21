// class FavoriteItem {
//   String title;
//   String subtitle;
//   String image;
//   String videoTrailer;
//   // double rating;
//   bool isFavorite;
//   bool isNotForMe;

//   FavoriteItem({
//     required this.title,
//     required this.subtitle,
//     required this.image,
//     // required this.rating,
//     this.isFavorite = false,
//     this.isNotForMe = false,
//     required this.videoTrailer,
//   });
// }

class FavoriteItem {
  final String title;
  final String subtitle;
  final String image;
  final String videoTrailer;

  FavoriteItem({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.videoTrailer,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'videoTrailer': videoTrailer,
    };
  }

  // Create from JSON
  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      videoTrailer: json['videoTrailer'] ?? '',
    );
  }
}