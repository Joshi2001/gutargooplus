import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gutrgoopro/home/model/banner_model.dart';
import 'package:http/http.dart' as http;

class BannerMovieService {
  static const String _baseUrl =
      'http://81.17.100.176/api/banners';

  static const String _moviesBaseUrl =
      'http://81.17.100.176/api/movies';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  static Future<BannerMovieListResponse> fetchBannerMovies({
    int page = 1,
    int limit = 20,
    bool? featured,
    String? sortBy,
    String order = 'desc',
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'page': '$page',
          'limit': '$limit',
          if (featured != null) 'featured': '$featured',
          if (sortBy != null) 'sortBy': sortBy,
          'order': order,
        },
      );
      debugPrint('📋 fetchBannerMovies → GET $uri');
      final response = await http.get(uri, headers: _headers);
      debugPrint('📋 fetchBannerMovies ← status: ${response.statusCode}');
      debugPrint('📋 fetchBannerMovies ← body: ${response.body}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      final result = BannerMovieListResponse.fromJson(json);
      debugPrint('📋 fetchBannerMovies → parsed ${result.data.length} items');
      return result;
    } catch (e) {
      debugPrint('❌ fetchBannerMovies ERROR: $e');
      rethrow;
    }
  }
  static Future<List<BannerMovie>> fetchAllBanners({int limit = 20}) async {
    try {
      final uri = Uri.parse(
        _baseUrl,
      ).replace(queryParameters: {'limit': '$limit', 'publishStatus': 'true'});
      debugPrint('🏠 fetchAllBanners → GET $uri');
      final response = await http.get(uri, headers: _headers);
      debugPrint('🏠 fetchAllBanners ← status: ${response.statusCode}');
      debugPrint('🏠 fetchAllBanners ← body: ${response.body}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      final banners = BannerMovieListResponse.fromJson(
        json,
      ).data.where((b) => b.publishStatus).toList();
      debugPrint('🏠 fetchAllBanners → ${banners.length} published banners');
      return banners;
    } catch (e) {
      debugPrint('❌ fetchAllBanners ERROR: $e');
      return [];
    }
  }

  // ── Fetch featured banners ─────────────────────────────────────────────────
  static Future<List<BannerMovie>> fetchFeaturedBanners({
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(
        _baseUrl,
      ).replace(queryParameters: {'limit': '$limit', 'publishStatus': 'true'});
      debugPrint('⭐ fetchFeaturedBanners → GET $uri');
      final response = await http.get(uri, headers: _headers);
      debugPrint('⭐ fetchFeaturedBanners ← status: ${response.statusCode}');
      debugPrint('⭐ fetchFeaturedBanners ← body: ${response.body}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      final banners = BannerMovieListResponse.fromJson(
        json,
      ).data.where((b) => b.publishStatus).toList();
      debugPrint('⭐ fetchFeaturedBanners → ${banners.length} featured banners');
      return banners;
    } catch (e) {
      debugPrint('❌ fetchFeaturedBanners ERROR: $e');
      return [];
    }
  }

  // ── Fetch trending banners ─────────────────────────────────────────────────
  static Future<List<BannerMovie>> fetchTrendingBanners({
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'limit': '$limit',
          'sortBy': 'createdAt',
          'order': 'desc',
        },
      );
      debugPrint('🔥 fetchTrendingBanners → GET $uri');
      final response = await http.get(uri, headers: _headers);
      debugPrint('🔥 fetchTrendingBanners ← status: ${response.statusCode}');
      debugPrint('🔥 fetchTrendingBanners ← body: ${response.body}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      final banners = BannerMovieListResponse.fromJson(json).data;
      debugPrint(
        '🔥 fetchTrendingBanners → ${banners.length} trending banners',
      );
      return banners;
    } catch (e) {
      debugPrint('❌ fetchTrendingBanners ERROR: $e');
      return [];
    }
  }

  static Future<BannerMovie?> fetchBannerById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/$id');
      debugPrint('🔍 fetchBannerById → GET $uri (id: $id)');
      final response = await http.get(uri, headers: _headers);
      debugPrint('🔍 fetchBannerById ← status: ${response.statusCode}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      debugPrint('🔍 fetchBannerById response: $json');

      if (json['data'] != null) {
        debugPrint('🔍 fetchBannerById → parsed from json[data]');
        return BannerMovie.fromJson(json['data']);
      } else if (json['_id'] != null) {
        debugPrint('🔍 fetchBannerById → parsed directly from root json');
        return BannerMovie.fromJson(json);
      }

      debugPrint('⚠️ fetchBannerById → no data found for id: $id');
      return null;
    } catch (e) {
      debugPrint('❌ fetchBannerById ERROR: $e');
      return null;
    }
  }

  static Future<List<BannerMovie>> searchBanners(
    String query, {
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(
        _baseUrl,
      ).replace(queryParameters: {'search': query, 'limit': '$limit'});
      debugPrint('🔎 searchBanners → GET $uri (query: "$query")');
      final response = await http.get(uri, headers: _headers);
      debugPrint('🔎 searchBanners ← status: ${response.statusCode}');
      debugPrint('🔎 searchBanners ← body: ${response.body}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      final banners = BannerMovieListResponse.fromJson(json).data;
      debugPrint('🔎 searchBanners → ${banners.length} results for "$query"');
      return banners;
    } catch (e) {
      debugPrint('❌ searchBanners ERROR: $e');
      return [];
    }
  }

  static Future<List<BannerMovie>> fetchPublishedBanners({
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(
        _baseUrl,
      ).replace(queryParameters: {'publishStatus': 'true', 'limit': '$limit'});
      debugPrint('✅ fetchPublishedBanners → GET $uri');
      final response = await http.get(uri, headers: _headers);
      debugPrint('✅ fetchPublishedBanners ← status: ${response.statusCode}');
      debugPrint('✅ fetchPublishedBanners ← body: ${response.body}');
      _checkStatus(response);
      final json = jsonDecode(response.body);
      final banners = BannerMovieListResponse.fromJson(json).data;
      debugPrint(
        '✅ fetchPublishedBanners → ${banners.length} published banners',
      );
      return banners;
    } catch (e) {
      debugPrint('❌ fetchPublishedBanners ERROR: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchMovieDetail(String movieId) async {
    try {
      final uri = Uri.parse('$_moviesBaseUrl/$movieId'); // fetch by ID directly
      debugPrint('🎬 Fetching movie detail: $uri');

      final response = await http.get(uri, headers: _headers);
      _checkStatus(response);

      final json = jsonDecode(response.body);
      if (json['data'] != null) {
        debugPrint('🎬 Found movie: ${json['data']['movieTitle']}');
        return json['data'] as Map<String, dynamic>;
      }

      debugPrint('❌ Movie not found for ID: $movieId');
      return null;
    } catch (e) {
      debugPrint('fetchMovieDetail ERROR: $e');
      return null;
    }
  }

  static Future<String?> fetchMoviePlayUrl(String movieId) async {
    try {
      debugPrint('▶️ fetchMoviePlayUrl → resolving for movieId: $movieId');
      final detail = await fetchMovieDetail(movieId);
      if (detail == null) {
        debugPrint(
          '⚠️ fetchMoviePlayUrl → no detail found for movieId: $movieId',
        );
        return null;
      }

      final url = detail['videoStreamUrl']?.toString().isNotEmpty == true
          ? detail['videoStreamUrl'].toString()
          : detail['customVideoUrl']?.toString().isNotEmpty == true
          ? detail['customVideoUrl'].toString()
          : (detail['movieFile'] as Map?)?['hlsUrl']?.toString().isNotEmpty ==
                true
          ? (detail['movieFile'] as Map)['hlsUrl'].toString()
          : (detail['movieFile'] as Map?)?['url']?.toString();

      if (url == null || url.isEmpty) {
        debugPrint(
          '❌ fetchMoviePlayUrl → no valid play URL for movie $movieId',
        );
        return null;
      }

      debugPrint('▶️ fetchMoviePlayUrl → resolved playUrl: "$url"');
      return url;
    } catch (e) {
      debugPrint('❌ fetchMoviePlayUrl ERROR: $e');
      return null;
    }
  }

  static Future<String> fetchMovieTrailerUrl(String movieId) async {
    try {
      debugPrint('🎞️ fetchMovieTrailerUrl → resolving for movieId: $movieId');
      final detail = await fetchMovieDetail(movieId);
      if (detail == null) {
        debugPrint(
          '⚠️ fetchMovieTrailerUrl → no detail found for movieId: $movieId',
        );
        return '';
      }

      final url = detail['trailerStreamUrl']?.toString().isNotEmpty == true
          ? detail['trailerStreamUrl'].toString()
          : detail['customTrailerUrl']?.toString().isNotEmpty == true
          ? detail['customTrailerUrl'].toString()
          : (detail['trailer'] as Map?)?['hlsUrl']?.toString().isNotEmpty ==
                true
          ? (detail['trailer'] as Map)['hlsUrl'].toString()
          : (detail['trailer'] as Map?)?['url']?.toString() ?? '';

      if (url.isEmpty) {
        debugPrint(
          '⚠️ fetchMovieTrailerUrl → no trailer URL found for movie $movieId',
        );
      } else {
        debugPrint('🎞️ fetchMovieTrailerUrl → resolved trailerUrl: "$url"');
      }

      return url;
    } catch (e) {
      debugPrint('❌ fetchMovieTrailerUrl ERROR: $e');
      return '';
    }
  }

  static void _checkStatus(http.Response response) {
    debugPrint(
      '🌐 _checkStatus → statusCode: ${response.statusCode}, reason: ${response.reasonPhrase}',
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        '❌ _checkStatus → HTTP error: ${response.statusCode} ${response.reasonPhrase}',
      );
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
}
