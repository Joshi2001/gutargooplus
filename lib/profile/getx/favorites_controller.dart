
import 'package:get/get.dart';
import 'package:gutrgoopro/profile/model/favorite_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesController extends GetxController {
  var favorites = <FavoriteItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  void addFavorite(FavoriteItem item) {
    if (!favorites.any((e) => e.videoTrailer == item.videoTrailer)) {
      favorites.add(item);
      favorites.refresh(); // 👈 Force UI update
      saveFavorites();
      print('✅ Added to favorites: ${item.title}');
    }
  }

  void removeByvideoTrailer(String url) {
    favorites.removeWhere((item) => item.videoTrailer == url);
    favorites.refresh(); // 👈 Force UI update
    saveFavorites();
    print('❌ Removed from favorites for: $url');
  }

  void toggleFavorite(int index) {
    if (index >= 0 && index < favorites.length) {
      favorites.removeAt(index);
      favorites.refresh(); // 👈 Force UI update
      saveFavorites();
    }
  }

  bool isFavorite(String videoTrailer) {
    final result = favorites.any((e) => e.videoTrailer == videoTrailer);
    return result;
  }

  bool isInMyList(String videoTrailer) {
    return favorites.any((e) => e.videoTrailer == videoTrailer);
  }

  void clearAll() {
    favorites.clear();
    favorites.refresh(); // 👈 Force UI update
    saveFavorites();
  }

  int get favoritesCount => favorites.length;

  Future<void> saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> favoritesList = 
          favorites.map((item) => item.toJson()).toList();
      await prefs.setString('favorites', json.encode(favoritesList));
      print('💾 Saved ${favorites.length} favorites');
    } catch (e) {
      print('❌ Error saving favorites: $e');
    }
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString('favorites');
      
      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        favorites.value = decoded
            .map((item) => FavoriteItem.fromJson(item))
            .toList();
        print('📂 Loaded ${favorites.length} favorites');
      } else {
        print('📂 No saved favorites found');
      }
    } catch (e) {
      print('❌ Error loading favorites: $e');
    }
  }
}