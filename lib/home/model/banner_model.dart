import 'package:flutter/foundation.dart';

// ── Cast Member ──────────────────────────────────────────────────────────────
class BannerCastMember {
  final String name;
  final String role;
  final String character;
  final String imageUrl;

  const BannerCastMember({
    required this.name,
    required this.role,
    required this.character,
    required this.imageUrl,
  });

  bool get isActor => role.isEmpty || role.toLowerCase() == 'actor';

  factory BannerCastMember.fromJson(Map<String, dynamic> json) {
    final role = json['role']?.toString() ?? '';
    return BannerCastMember(
      name: json['name']?.toString() ?? '',
      role: role,
      character: json['character']?.toString() ?? '',
      imageUrl: role.isEmpty
          ? json['profileImage']?.toString() ?? ''
          : json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'character': character,
        'image': imageUrl,
      };

  @override
  String toString() =>
      'BannerCastMember(name: $name, role: $role, character: $character)';
}

// ── Movie Details (nested inside movieId for single_movie banners) ───────────
class MovieIdDetails {
  final String id;
  final String movieTitle;
  final int releaseYear;
  final String verticalPosterUrl;

  const MovieIdDetails({
    required this.id,
    required this.movieTitle,
    required this.releaseYear,
    required this.verticalPosterUrl,
  });

  factory MovieIdDetails.fromJson(Map<String, dynamic> json) {
    return MovieIdDetails(
      id: json['_id']?.toString() ?? '',
      movieTitle: json['movieTitle']?.toString() ?? '',
      releaseYear: (json['releaseYear'] as num?)?.toInt() ?? 0,
      verticalPosterUrl: json['verticalPoster']?['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'movieTitle': movieTitle,
        'releaseYear': releaseYear,
        'verticalPoster': {'url': verticalPosterUrl},
      };

  @override
  String toString() =>
      'MovieIdDetails(id: $id, title: $movieTitle, year: $releaseYear)';
}

// ── Banner Movie ─────────────────────────────────────────────────────────────
class BannerMovie {
  final String id;
  final String title;
  final String description;
  final String mobileImage; // bannerImage.url
  final String logoImage; // logoImage.url
  final String movieUrl;
  final String trailerUrl;
  final List<String> genres;
  final double imdbRating;
  final String ageLimit;
  final bool publishStatus;
  final bool isActive;
  final List<BannerCastMember> cast;

  // Banner-specific fields
  final String bannerType; // "single_movie" | "category_movies"
  final String visibleOn; // "home"
  final String? categoryId;
  final String? categoryName;
  final int displayOrder;

  // movieId — either a plain String ID or a full MovieIdDetails object
  final String? movieId;
  final MovieIdDetails? movieDetails;

  const BannerMovie({
    required this.id,
    required this.title,
    this.description = '',
    this.mobileImage = '',
    this.logoImage = '',
    this.movieUrl = '',
    this.trailerUrl = '',
    this.genres = const [],
    this.imdbRating = 0.0,
    this.ageLimit = 'U/A',
    this.publishStatus = false,
    this.isActive = true,
    this.cast = const [],
    this.bannerType = '',
    this.visibleOn = 'home',
    this.categoryId,
    this.categoryName,
    this.displayOrder = 0,
    this.movieId,
    this.movieDetails,
  });

  // ── Convenience getters ───────────────────────────────────────────────────
  bool get isSingleMovie => bannerType == 'single_movie' || effectiveMovieId != null;
  bool get isCategoryBanner => bannerType == 'category_movies';

  /// The actual movie ID to use for API calls
  String? get effectiveMovieId => movieId ?? movieDetails?.id;

  /// Best poster image — falls back to verticalPoster from movieDetails
  String get posterImage =>
      mobileImage.isNotEmpty ? mobileImage : movieDetails?.verticalPosterUrl ?? '';

  List<BannerCastMember> get actors => cast.where((e) => e.isActor).toList();
  List<BannerCastMember> get crew => cast.where((e) => !e.isActor).toList();

  // ── fromJson ──────────────────────────────────────────────────────────────
  factory BannerMovie.fromJson(Map<String, dynamic> json) {
    // Helper: extract URL from nested {url, publicId} or flat string
    String extractUrl(dynamic field) {
      if (field == null) return '';
      if (field is String) return field;
      if (field is Map) return field['url']?.toString() ?? '';
      return '';
    }

    // Category
    final categoryRaw = json['categoryId'];
    String? categoryId;
    String? categoryName;
    if (categoryRaw is Map<String, dynamic>) {
      categoryId = categoryRaw['_id']?.toString();
      categoryName = categoryRaw['name']?.toString();
    } else {
      categoryId = categoryRaw?.toString();
    }

    // movieId — object (single_movie) or null/string
    final movieRaw = json['movieId'];
    String? movieId;
    MovieIdDetails? movieDetails;

    if (movieRaw is Map<String, dynamic>) {
      movieDetails = MovieIdDetails.fromJson(movieRaw);
      movieId = movieDetails.id;
    } else {
      movieId = movieRaw?.toString();
    }

    // Cast
    final castRaw = json['cast'] as List<dynamic>? ?? [];

    return BannerMovie(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mobileImage: extractUrl(json['bannerImage']),
      logoImage: extractUrl(json['logoImage']),
      movieUrl: json['movieUrl']?.toString() ?? '',
      trailerUrl: json['trailerUrl']?.toString() ?? '',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (categoryName != null ? [categoryName] : []),
      imdbRating: (json['imdbRating'] as num?)?.toDouble() ?? 0.0,
      ageLimit: json['ageLimit']?.toString() ?? 'U/A',
      publishStatus: json['publishStatus'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      cast: castRaw
          .map((e) => BannerCastMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      bannerType: json['bannerType']?.toString() ?? '',
      visibleOn: json['visibleOn']?.toString() ?? 'home',
      categoryId: categoryId,
      categoryName: categoryName,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      movieId: movieId,
      movieDetails: movieDetails,
    );
  }

  // ── toJson ────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'bannerImage': {'url': mobileImage},
        'logoImage': {'url': logoImage},
        'movieUrl': movieUrl,
        'trailerUrl': trailerUrl,
        'genres': genres,
        'imdbRating': imdbRating,
        'ageLimit': ageLimit,
        'publishStatus': publishStatus,
        'isActive': isActive,
        'cast': cast.map((e) => e.toJson()).toList(),
        'bannerType': bannerType,
        'visibleOn': visibleOn,
        'categoryId': categoryId,
        'displayOrder': displayOrder,
        'movieId': movieDetails?.toJson() ?? movieId,
      };

  // ── Legacy map for existing UI widgets ────────────────────────────────────
  Map<String, dynamic> toLegacyMap() => {
        'id': id,
        'image': posterImage,
        'title': title,
        'subtitle': genres.join(', '),
        'videoTrailer': trailerUrl.isNotEmpty ? trailerUrl : movieUrl,
        'videoMovies': movieUrl,
        'dis': description,
        'logoImage': logoImage,
        'live': false,
        'imdbRating': imdbRating,
        'ageRating': ageLimit,
        'movieId': effectiveMovieId,
        'isSingleMovie': isSingleMovie,
      };

  // ── copyWith ──────────────────────────────────────────────────────────────
  BannerMovie copyWith({
    String? id,
    String? title,
    String? description,
    String? mobileImage,
    String? logoImage,
    String? movieUrl,
    String? trailerUrl,
    List<String>? genres,
    double? imdbRating,
    String? ageLimit,
    bool? publishStatus,
    bool? isActive,
    List<BannerCastMember>? cast,
    String? bannerType,
    String? visibleOn,
    String? categoryId,
    String? categoryName,
    int? displayOrder,
    String? movieId,
    MovieIdDetails? movieDetails,
  }) {
    return BannerMovie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mobileImage: mobileImage ?? this.mobileImage,
      logoImage: logoImage ?? this.logoImage,
      movieUrl: movieUrl ?? this.movieUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      genres: genres ?? this.genres,
      imdbRating: imdbRating ?? this.imdbRating,
      ageLimit: ageLimit ?? this.ageLimit,
      publishStatus: publishStatus ?? this.publishStatus,
      isActive: isActive ?? this.isActive,
      cast: cast ?? this.cast,
      bannerType: bannerType ?? this.bannerType,
      visibleOn: visibleOn ?? this.visibleOn,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      displayOrder: displayOrder ?? this.displayOrder,
      movieId: movieId ?? this.movieId,
      movieDetails: movieDetails ?? this.movieDetails,
    );
  }

  @override
  String toString() =>
      'BannerMovie(id: $id, title: $title, type: $bannerType, movieId: $movieId)';
}

// ── List Response ─────────────────────────────────────────────────────────────
class BannerMovieListResponse {
  final bool success;
  final List<BannerMovie> data;

  const BannerMovieListResponse({
    required this.success,
    required this.data,
  });

  factory BannerMovieListResponse.fromJson(Map<String, dynamic> json) {
    return BannerMovieListResponse(
      success: json['success'] as bool? ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => BannerMovie.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data.map((e) => e.toJson()).toList(),
      };
}