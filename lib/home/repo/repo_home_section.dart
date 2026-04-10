import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gutrgoopro/home/model/home_section_model.dart';
import 'package:gutrgoopro/home/model/movie_model.dart';
import 'package:gutrgoopro/uitls/api.dart';
import 'package:http/http.dart' as http;

class HomeSectionRepository {
  Future<Map<String, MovieModel>> _fetchAllMovies() async {
    try {
      final res = await http
          .get(Uri.parse(MyApi.movies), headers: {
        'Content-Type': 'application/json'
      }).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        debugPrint('❌ Movies API failed: ${res.statusCode}');
        return {};
      }

      final decoded = json.decode(res.body);

      final data = decoded['data'];
      if (data is! List) {
        debugPrint('❌ Movies API invalid format');
        return {};
      }

      final map = <String, MovieModel>{};

      for (var item in data) {
        try {
          final movie = MovieModel.fromJson(item);
          map[movie.id] = movie;
        } catch (e) {
          debugPrint('❌ Movie parse error: $e');
        }
      }

      debugPrint('🎬 Loaded ALL movies: ${map.length}');
      return map;

    } catch (e) {
      debugPrint('❌ _fetchAllMovies error: $e');
      return {};
    }
  }

  /// 🔥 MAIN FUNCTION
  Future<List<HomeSectionModel>> fetchSections({String? categoryId}) async {
    try {
      String url = MyApi.sections;

      if (categoryId != null && categoryId.isNotEmpty) {
        url += '?categoryId=$categoryId';
      }

      debugPrint('🌐 API URL: $url');

      final response = await http
          .get(Uri.parse(url), headers: {
        'Content-Type': 'application/json'
      }).timeout(const Duration(seconds: 15));

      debugPrint('📡 STATUS: ${response.statusCode}');
      debugPrint('📦 RAW RESPONSE: ${response.body}');

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

      /// ✅ Parse sections
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

      /// ✅ Remove duplicates
      final seen = <String>{};
      final deduped = allParsed.where((s) {
        final key =
            '${s.title.trim().toLowerCase()}__${s.categoryId ?? 'null'}';
        return seen.add(key);
      }).toList();

      debugPrint('📊 After dedup: ${deduped.length} sections');

      /// 🔥 IMPORTANT: Fetch all movies ONCE
      final movieMap = await _fetchAllMovies();

      /// 🔥 Attach movies to sections
      final populated = deduped.map((section) {
        if (section.movieIds.isEmpty) {
          debugPrint(
              '🚫 Section "${section.title}" has no movie IDs — skipping');
          return null;
        }

        final movies = section.movieIds
            .map((id) => movieMap[id])
            .whereType<MovieModel>()
            .toList();

        if (movies.isEmpty) {
          debugPrint(
              '🚫 Section "${section.title}" — no movies matched');
          return null;
        }

        debugPrint(
            '✅ Section "${section.title}" → ${movies.length} movies');

        return section.copyWith(items: movies);
      }).toList();

      /// ✅ Final clean list
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
