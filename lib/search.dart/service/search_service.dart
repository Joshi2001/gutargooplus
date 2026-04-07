import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gutrgoopro/home/model/movie_model.dart';

class SearchService {
  static const String _baseUrl =
      'http://81.17.100.176/api/search';
  static const Duration _timeout = Duration(seconds: 15);
  Future<List<MovieModel>> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      throw SearchException('Query cannot be empty');
    }
    http.Response? response;
    try {
     final uri = Uri.parse(_baseUrl).replace(
  queryParameters: {'query': query.trim()},
);

      print('🔍 API Request: $uri');

      response = await http
          .get(                              
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Raw Response: ${response.body}');

      return _handleResponse(response);

    } on http.ClientException catch (e) {
      throw SearchException('Network error: ${e.message}');
    } on FormatException catch (e) {
      print('❌ JSON Parse failed: $e');
      print('❌ Body was: ${response?.body}');
      throw SearchException('Invalid response format');
    } catch (e) {
      throw SearchException('Unexpected error: $e');
    }
  }

  /// Handle API response
  List<MovieModel> _handleResponse(http.Response response) {
    if (response.statusCode >= 500) {
      throw SearchException('Server error (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw SearchException('Invalid response format');
    }

    final success = decoded['success'] as bool? ?? false;

    if (!success) {
      final message = decoded['message']?.toString() ?? 'Search failed';
      throw SearchException(message);
    }

    final results = decoded['data'];

    if (results == null) return [];

    if (results is! List) {
      throw SearchException('Invalid data format');
    }

    return results
        .map((item) {
          try {
            return MovieModel.fromJson(
              item is Map<String, dynamic> ? item : {},
            );
          } catch (e) {
            print('⚠️ Error parsing movie: $e');
            return null;
          }
        })
        .whereType<MovieModel>()
        .toList();
  }
}

/// Custom Exception
class SearchException implements Exception {
  final String message;

  SearchException(this.message);

  @override
  String toString() => message;
}