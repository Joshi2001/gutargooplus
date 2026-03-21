import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchControllerX extends GetxController {
  var query = ''.obs;
  var recentSearches = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
  }

  // Add search to recent
  void addSearch(String search, {bool updateQuery = false}) {
    if (search.trim().isEmpty) return;
    
    final trimmed = search.trim();
    
    // Remove if already exists
    recentSearches.remove(trimmed);
    
    // Add to beginning
    recentSearches.insert(0, trimmed);
    
    // Keep only last 10 searches
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }
    
    // Save to storage
    saveRecentSearches();
    
    // Update query if needed
    if (updateQuery) {
      query.value = trimmed;
    }
    
    print('✅ Recent searches: ${recentSearches.toList()}');
  }

  // Remove single search
  void removeSearch(String search) {
    recentSearches.remove(search);
    saveRecentSearches();
  }

  // Clear all searches
  void clearAll() {
    recentSearches.clear();
    saveRecentSearches();
  }

  // Save to SharedPreferences
  Future<void> saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', recentSearches.toList());
  }

  // Load from SharedPreferences
  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('recent_searches') ?? [];
    recentSearches.value = saved;
    print('📂 Loaded recent searches: $saved');
  }
}