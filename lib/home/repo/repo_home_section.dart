import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gutrgoopro/home/model/home_section_model.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:http/http.dart' as http;

class HomeSectionRepository {
  static const String _baseUrl =
      'http://81.17.100.176/api';

  Future<MovieModel?> _fetchMovieById(String movieId) async {
    try {
      final uri = Uri.parse('$_baseUrl/movies/$movieId');
      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        Map<String, dynamic>? movieJson;

        if (decoded is Map<String, dynamic>) {
          movieJson = decoded['data'] as Map<String, dynamic>? ??
              decoded['movie'] as Map<String, dynamic>? ??
              (decoded.containsKey('_id') ? decoded : null);
        }

        if (movieJson != null) {
          return MovieModel.fromJson(movieJson);
          // ✅ No publishStatus filter here — admin put it in section intentionally
        }
      }
    } catch (e) {
      debugPrint('❌ _fetchMovieById($movieId) error: $e');
    }
    return null;
  }

  Future<List<MovieModel>> _fetchMoviesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final results = await Future.wait(ids.map(_fetchMovieById));
    return results.whereType<MovieModel>().toList();
  }

  Future<List<HomeSectionModel>> fetchSections({String? categoryId}) async {
    try {
      String url = '$_baseUrl/admin/sections';
      if (categoryId != null && categoryId.isNotEmpty) {
        url += '?categoryId=$categoryId';
      }

      debugPrint('🌐 API URL: $url');
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      debugPrint('📡 STATUS: ${response.statusCode}');

      if (response.statusCode != 200) return [];

      final decoded = json.decode(response.body);
      List<dynamic> rawList = [];

      if (decoded is Map<String, dynamic>) {
        rawList = (decoded['data'] ?? decoded['sections'] ?? []) as List<dynamic>;
      } else if (decoded is List) {
        rawList = decoded;
      } else {
        return [];
      }

      debugPrint('📊 Raw sections from API: ${rawList.length}');

      final allParsed = rawList
          .map((e) {
            try {
              return HomeSectionModel.fromJson(e as Map<String, dynamic>);
            } catch (err) {
              debugPrint('❌ Section parse error: $err');
              return null;
            }
          })
          .whereType<HomeSectionModel>()
          .where((s) => s.isActive)
          .toList();

      // Deduplicate by title + categoryId
      final seen = <String>{};
      final deduped = allParsed.where((s) {
        final key = '${s.title.trim().toLowerCase()}__${s.categoryId ?? 'null'}';
        return seen.add(key);
      }).toList();

      debugPrint('📊 After dedup: ${deduped.length} sections');

      // Populate movies for sections that have IDs
      final populated = await Future.wait(
        deduped.map((section) async {
          if (section.movieIds.isEmpty) {
            debugPrint('🚫 Section "${section.title}" has no movie IDs — skipping');
            return null;
          }
          final movies = await _fetchMoviesByIds(section.movieIds);
          if (movies.isEmpty) {
            debugPrint('🚫 Section "${section.title}" — no movies fetched');
            return null;
          }
          debugPrint('✅ Section "${section.title}" → ${movies.length} movies loaded');
          return section.copyWith(items: movies);
        }),
      );

      final result = populated
          .whereType<HomeSectionModel>()
          .where((s) => s.items.isNotEmpty)
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      debugPrint('🔥 FINAL SECTIONS WITH ITEMS: ${result.length}');
      return result;
    } catch (e) {
      debugPrint('❌ fetchSections EXCEPTION: $e');
      return [];
    }
  }
}