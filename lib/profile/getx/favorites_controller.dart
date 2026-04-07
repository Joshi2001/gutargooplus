import 'package:get/get.dart';
import '../model/favorite_model.dart';

class FavoritesController extends GetxController {
  var favorites = <FavoriteItem>[].obs;

  // ✅ Sirf ADD karta hai, remove nahi
  void addFavorite(FavoriteItem item) {
    if (item.id.isEmpty) {
      print("❌ ERROR: Movie ID is empty");
      return;
    }

    final isFav = favorites.any((e) => e.id == item.id);
    if (!isFav) {
      favorites.add(item);
      print("✅ Added to favorites: ${item.id}");
    } else {
      print("⚠️ Already in favorites: ${item.id}");
    }
  }

  // ✅ Sirf REMOVE karta hai
  void removeFavorite(String id) {
    favorites.removeWhere((e) => e.id == id);
    print("❌ Removed from favorites: $id");
    favorites.refresh();
  }

  // Toggle abhi bhi rakh sakte ho agar kahin aur use ho
  void toggleFavorite(FavoriteItem item) {
    if (isFavorite(item.id)) {
      removeFavorite(item.id);
    } else {
      addFavorite(item);
    }
  }

  bool isFavorite(String id) {
    return favorites.any((e) => e.id == id);
  }
}