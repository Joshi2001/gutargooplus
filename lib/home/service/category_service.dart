import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gutrgoopro/home/model/category_model.dart';

class CategoryService {
  // Replace with your actual base URL
  static const String _baseUrl = 'http://81.17.100.176/api/public';

  static Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/category'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['success'] == true && json['data'] != null) {
          final List<dynamic> data = json['data'];
          return data.map((item) => CategoryModel.fromJson(item)).toList();
        }

        return [];
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('CategoryService error: $e');
    }
  }
}